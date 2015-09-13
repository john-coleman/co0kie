class Co0kie
  class Cutter
    class Package
      def initialize(package, version = nil)
        @package = package
        @version = version
      end

      def install
        cmd = "sudo apt-get -qy install #{@package}"
        cmd << " @#{@version}" if @version
        cmd
      end

      def status
        "sudo dpkg -s #{@package} | grep 'Status: '"
      end

      %w{check purge remove}.each do |action|
        define_method(action) do
          "sudo apt-get -qy #{@action} #{@package}"
        end
      end
    end
  end
end

