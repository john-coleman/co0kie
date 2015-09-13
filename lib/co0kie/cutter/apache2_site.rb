class Co0kie
  class Cutter
    class Apache2Site
      def initialize(site)
        @site = site
      end

      def disable
        "sudo /usr/sbin/a2dissite #{@site}"
      end

      def enable
        "sudo /usr/sbin/a2ensite #{@site}"
      end
    end
  end
end
