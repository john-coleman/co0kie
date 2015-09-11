require 'json'
require 'pp'
require_relative '../lib/co0kie'


def box(dough)
  pp 'Wonderful web_server'
  commands = []
  config = JSON.parse(File.read(File.expand_path('../../config/web_server.json', __FILE__)))
  #config = JSON.parse(File.read(File.expand_path('../../config/db_server.json', __FILE__)))
  pp config

  %w(apache2 libapache2-mod-php5 php5-mysqln php5-apcu).each do |pkg|
    commands << Co0kie::Cutter::Package.new(pkg).install
  end

  commands << Co0kie::Cutter::Directory.new(config['docroot']['path'],
                                            config['docroot']['owner'],
                                            config['docroot']['group'],
                                            config['docroot']['mode']).create

  app = File.read(File.expand_path('../../files/hello_world/index.php', __FILE__))
  commands << Co0kie::Cutter::File.new(File.join(config['docroot']['path'], 'index.php'),
                                       config['docroot']['owner'],
                                       config['docroot']['group'],
                                       644).create(app)

  commands << Co0kie::Cutter::Apache2Site.new('default').disable

  apache2_vhost_src = File.read(File.expand_path('../../templates/web_server/helloworld.com.erb', __FILE__))
  apache2_vhost = Co0kie::Cutter::Template.new(apache2_vhost_src, config).render
  commands << Co0kie::Cutter::File.new('/etc/apache2/sites-available/helloworld.com',
                                       'root',
                                       'root',
                                       644).create(apache2_vhost)
  commands << Co0kie::Cutter::Apache2Site.new('helloworld.com').enable

  pp 'Commands:'
  pp commands

  #commands.each do |cmd|
  #  dough.bake(cmd)
  #end
end
