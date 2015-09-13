require 'json'
require 'pp'
require_relative '../lib/co0kie'


def box(dough)
  pp 'Bland base_server'
  commands = []
  config = JSON.parse(File.read(File.expand_path('../../config/base_server.json', __FILE__)))
  pp config

  config['packages'].each do |pkg|
    commands << Co0kie::Cutter::Package.new(pkg).install
  end

  pp 'Commands:'
  pp commands

  commands.each do |cmd|
    dough.bake(cmd)
  end
end
