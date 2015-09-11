require 'pp'
require_relative '../lib/co0kie'

pp 'Delectable db_server'

def box(dough)
  commands = []

  %w(mysql-server mysql-client).each do |pkg|
    commands << Co0kie::Cutter::Package.new(pkg).install
  end

  pp 'Commands:'
  pp commands

  #commands.each do |cmd|
  #  dough.bake(cmd)
  #end
end
