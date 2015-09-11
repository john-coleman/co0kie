class Co0kie
  class Cutter
    class Service
      def initialize(service)
        @service = service
      end

      %w(disable enable reload restart start status stop).each do |action|
        define_method(action) do
          cmd = "service #{@service} #{action}"
        end
      end
    end
  end
end
