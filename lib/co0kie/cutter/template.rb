require 'erb'

class Co0kie
  class Cutter
    class Template
      def initialize(template, variables)
        @template = template
        @variables = variables
      end

      def render
        b = binding
        output = ERB.new(@template).result b
      end
    end
  end
end
