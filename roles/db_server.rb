require'json'
require 'pp'
require_relative '../lib/co0kie'

def box(dough)
  pp 'Delectable db_server'
  commands = []
  config = JSON.parse(File.read(File.expand_path('../../config/db_server.json', __FILE__)))
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

echo '###TRIAGE Clear processes hogging port3306'
for hoggypid in $(sudo lsof -i4:3306 | tr -s ' ' | grep -v 'COMMAND PID' | grep -v 'mysqld' | cut -f 2 -d ' '); do
  HOGPROC=$(ps -p $hoggypid -o comm=)
  NORMPROC=$(echo $HOGPROC | sed 's/mysqld/mysql/' | sed 's/named/bind/')
  echo "Process $hoggypid $NORMPROC has open filehandle for port3306"
  sudo service $NORMPROC stop; sudo kill -9 $hoggypid
done

echo '###TRIAGE Ensure we can resolv'
sudo /sbin/resolvconf -u
host example.com

echo '###TRIAGE Update APT cache'
sudo apt-get update
  ERMAGERD
  commands << triage

  mysql_server_seed_src = File.read(File.expand_path('../../templates/db_server/mysql-server_seed_src.erb', __FILE__))

  seed = Co0kie::Cutter::Template.new(mysql_server_seed_src, config).render
  commands << Co0kie::Cutter::Directory.new('/var/cache/local/preseeding',
                                       'root',
                                       'root',
                                       '0755').create
  commands << Co0kie::Cutter::File.new('/var/cache/local/preseeding/mysql-server.seed',
                                       'root',
                                       'root',
                                       '0600').create(seed)
  commands << "/usr/bin/debconf-set-selections /var/cache/local/preseeding/mysql-server.seed"

  %w(mysql-server mysql-client).each do |pkg|
    commands << Co0kie::Cutter::Package.new(pkg).install
  end

  commands << Co0kie::Cutter::Service.new('mysql').start

  pp 'Commands:'
  pp commands

  commands.each do |cmd|
    dough.bake(cmd)
  end
end
