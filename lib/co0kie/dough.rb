require_relative 'dough/local'
require_relative 'dough/ssh'

class Co0kie
  class Dough
    attr_accessor :dough

    def initialize(options = {})
      if options[:targets].empty?
        @dough = Co0kie::Dough::Local.new
      else
        @dough = Co0kie::Dough::Ssh.new(options)
      end
      @dough
    end

    def bake(cmd)
      @dough.bake(cmd)
    end
  end
end
