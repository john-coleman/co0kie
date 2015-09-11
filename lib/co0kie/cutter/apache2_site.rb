class Co0kie
  class Cutter
    class Apache2Site
      def initialize(site)
        @site = site
      end

      def disable
        "/usr/sbin/a2dissite #{@site}"
      end

      def enable
        "/usr/sbin/a2ensite #{@site}"
      end
    end
  end
end
