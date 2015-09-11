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
        source = File.read(@template)
        output = ERB.new(source).result b
      end
    end
  end
end
