module Co0kie
  class Dough
    class Local
      def initialize(options = {})
        @options = options
      end

      def bake(cmd)
        `#{cmd}`
      end
    end
  end
end
