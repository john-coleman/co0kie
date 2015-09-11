require'json'
require 'pp'
require_relative '../lib/co0kie'

def box(dough)
  pp 'Delectable db_server'
  commands = []
  config = JSON.parse(File.read(File.expand_path('../../config/db_server.json', __FILE__)))
  pp config

  mysql_server_seed_src = File.read(File.expand_path('../../templates/db_server/mysql-server_seed_src.erb', __FILE__))

  seed = Co0kie::Cutter::Template.new(mysql_server_seed_src, config).render
  commands << Co0kie::Cutter::File.new('/var/cache/local/preseeding/mysql-server.seed',
                                       'root',
                                       'root',
                                       '0600').create(seed)

  %w(mysql-server mysql-client).each do |pkg|
    commands << Co0kie::Cutter::Package.new(pkg).install
  end

  commands << Co0kie::Cutter::Service.new('mysql-server').start

  pp 'Commands:'
  pp commands

  #commands.each do |cmd|
  #  dough.bake(cmd)
  #end
end
