class Co0kie
  class Cutter
    class Package
      def initialize(package, version = nil)
        @package = package
        @version = version
      end

      def install
        cmd = "apt-get -qy install #{@package}"
        cmd << " @#{@version}" if @version
        cmd
      end

      def status
        "dpkg -s #{@package} | grep 'Status: '"
      end

      %w{check purge remove}.each do |action|
        define_method(action) do
          "apt-get -qy #{@action} #{@package}"
        end
      end
    end
  end
end

