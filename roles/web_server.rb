require_relative '../lib/co0kie'

def box(dough)
  pp 'Wonderful web_server'
  commands = []
  config = JSON.parse(File.read(File.expand_path('../../config/web_server.json', __FILE__)))
  pp config

  triage =<<-ERMAGERD
echo '###TRIAGE Report processes hogging deleted files and gently clear if necessary'
for messypid in $(sudo find /proc/*/fd -ls | grep '(deleted)' | cut -f 3 -d '/' | grep -v '^1$' | uniq); do
  SLOTHPROC=$(ps -p $messypid -o comm=)
  NORMPROC=$(echo $SLOTHPROC | sed 's/mysqld/mysql/' | sed 's/named/bind/')
  echo "Process $messypid $SLOTHPROC has open filehandle for deleted file(s):"
  sudo lsof -p $messypid | grep '(deleted)'

  if [ $(df --output=pcent / | tail -n 1 | cut -f 1 -d '%') -gt 89 ]; then
    echo "Disk usage >= 90% - attempting to restart offending processes!"
    sudo kill -HUP $messypid
    sudo service $NORMPROC restart
    sudo sync
  fi
done

echo '###TRIAGE Report processes still hogging deleted files and ruthlessly clear if necessary'
for messypid in $(sudo find /proc/*/fd -ls | grep '(deleted)' | cut -f 3 -d '/' | grep -v '^1$' | uniq); do
  SLOTHPROC=$(ps -p $messypid -o comm=)
  NORMPROC=$(echo $SLOTHPROC | sed 's/mysqld/mysql/' | sed 's/named/bind/')
  echo "Process $messypid $SLOTHPROC has open filehandle for deleted file(s):"
  sudo lsof -p $messypid | grep '(deleted)'
  if [ $(df --output=pcent / | tail -n 1 | cut -f 1 -d '%') -gt 89 ]; then
    echo "DANGER CLOSE! - Disk usage still >= 90% - attempting to kill offending processes!"
    sudo kill -9 $messypid
    sudo sync
  fi
done

echo '###TRIAGE Clear processes hogging port80'
for hoggypid in $(sudo lsof -i4:80 | tr -s ' ' | grep -v 'COMMAND PID' | grep -v 'apache2' | cut -f 2 -d ' '); do
  HOGPROC=$(ps -p $hoggypid -o comm=)
  NORMPROC=$(echo $HOGPROC | sed 's/mysqld/mysql/' | sed 's/named/bind/')
  echo "Process $hoggypid $NORMPROC has open filehandle for port80"
  sudo service $NORMPROC stop; sudo kill -9 $hoggypid
done

echo '###TRIAGE Ensure we can resolv'
sudo /sbin/resolvconf -u
host example.com

echo '###TRIAGE Update APT cache'
sudo apt-get update
  ERMAGERD
  commands << triage

  commands << Co0kie::Cutter::FirewallRule.new.flush('INPUT')

  %w(apache2 libapache2-mod-php5 php5-mysqlnd php5-apcu).each do |pkg|
    commands << Co0kie::Cutter::Package.new(pkg).install
  end

  commands << Co0kie::Cutter::Directory.new(config['docroot']['path'],
                                            dough.user,
                                            config['docroot']['group'],
                                            config['docroot']['mode']).create

  app = File.read(File.expand_path('../../files/hello_world/index.php', __FILE__))
  puts app

  commands << Co0kie::Cutter::File.new(File.join(config['docroot']['path'], 'index.php'),
                                       config['docroot']['owner'],
                                       config['docroot']['group'],
                                       644).create(app)
  # ToDo: SFTP :)
  #commands << Co0kie::Cutter::Directory.new(config['docroot']['path'],
  #                                          config['docroot']['owner'],
  #                                          config['docroot']['group'],
  #                                          config['docroot']['mode']).create
  #commands << Co0kie::Cutter::File.new(File.join(config['docroot']['path'], 'index.php'),
  #                                     config['docroot']['owner'],
  #                                     config['docroot']['group'],
  #                                     644).copy(File.expand_path('../../files/hello_world/index.php', __FILE__), dough)

  commands << Co0kie::Cutter::Apache2Site.new('000-default').disable

  apache2_vhost_src = File.read(File.expand_path('../../templates/web_server/helloworld.com.erb', __FILE__))
  apache2_vhost = Co0kie::Cutter::Template.new(apache2_vhost_src, config).render
  commands << Co0kie::Cutter::File.new('/etc/apache2/sites-available/helloworld.com.conf',
                                       'root',
                                       'root',
                                       644).create(apache2_vhost)
  commands << Co0kie::Cutter::Apache2Site.new('helloworld.com').enable
  commands << Co0kie::Cutter::Service.new('apache2').reload

  pp 'Commands:'
  pp commands

  commands.each do |cmd|
    dough.bake(cmd)
  end
end
