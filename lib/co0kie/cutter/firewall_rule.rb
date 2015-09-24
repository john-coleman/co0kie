class Co0kie
  class Cutter
    class FirewallRule
      def add(params = {})
        cmd = "iptables -A"
        parse_params(cmd, params)
      end

      def remove(params = {})
        cmd = "iptables -D"
        parse_params(cmd, params)
      end

      def flush(chain = nil)
        cmd = "sudo iptables -F"
        cmd << " #{chain}" if chain
      end

      def restore(rule_file = 'rules.fw')
        "sudo iptables-restore < /etc/iptables/#{rule_file}"
      end

      def restore_on_boot(rule_file = 'rules.fw')
        cmd = "sudo iptables-restore < /etc/iptables/#{rule_file}"
        cmd << "if [ -z $(grep 'iptables-restore < /etc/iptables/#{rule_file}' /etc/rc.local ] ; then echo 'iptables-restore < /etc/iptables/#{rule_file}' >> /etc/rc.local; fi"
      end

      def save(rule_file = 'rules.fw')
        cmd = "if [ ! -d \"/etc/iptables\" ]; then sudo mkdir -p \"/etc/iptables\"; else echo \"Directory #{iptables} exists!\"; fi"
        cmd << "iptables-save > /etc/iptables/#{rule_file}"
      end

      %w{check purge remove}.each do |action|
        define_method(action) do
          "sudo apt-get -qy #{@action} #{@package}"
        end
      end

      private

      def parse_params(cmd, rulz)
        if rulz[:chain]
          cmd << " #{rulz[:chain]}"
        else
          raise "Chain must be specified! Params: #{rulz}"
        end
        if /(all|icmp|tcp|udp)/.match(params[:protocol])
          cmd << " -p #{rulz[:protocol]}"
        else
          raise "Protocol '#{rulz[:protocol]}' is not one of all, icmp, tcp or udp"
        end
        %w( destination dport source sport ).each do |opt|
          cmd << "--#{opt} #{rulz[opt.to_sym]}" if rulz[opt.to_sym]
        end
        cmd << "--icmp-type #{rulz[:icmp_type]}" if rulz[:icmp_type]
        cmd << "-i #{rulz[:in_interface]}" if rulz[:in_interface]
        cmd << "-o #{rulz[:out_interface]}" if rulz[:out_interface]
        if /(ACCEPT|DROP|QUEUE|RETURN)/.match(rulz[:action])
          cmd << "-j #{rulz[:action]}" if rulz[:action]
        else
          raise "Action '#{rulz[:action]}' is not one of ACCEPT, DROP, QUEUE or RETURN"
        end
        cmd
      end
    end
  end
end

