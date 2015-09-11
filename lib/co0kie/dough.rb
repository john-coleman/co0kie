class Co0kie
  class Dough
    def initialize(options = {})
      if options[:targets].empty?
        require_relative 'dough/local'
        @dough = Co0kie::Dough::Local.new
      else
        require_relative 'dough/ssh'
        @dough = Co0kie::Dough::Ssh.new(options)
      end
    end

    def bake(cmd)
      @dough.bake(cmd)
    end
  end
end
