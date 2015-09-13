class Co0kie
  class Cli
    def self.parse(args)
      cli_options = Hash.new
      cli_options[:targets] = []
      cli_options[:role] = :base_server

      OptionParser.new do |o|
        o.banner = 'Usage: co0kie [options]'
        o.separator ""
        o.separator "Specific options:"
        o.on('-P', '--password [PASSWORD]', 'Password to use for remote provisioning') do |pass|
          cli_options[:password] = pass
        end
        o.on('-p', '--port [PORT]', 'Port to use for remote provisioning') do |port|
          cli_options[:port] = port
        end
        o.on('-r', '--role [ROLE]', [:base_server, :db_server, :web_server], 'Role to configure. Eg. base_server (default), db_server, web_server') do |role|
          cli_options[:role] = role
        end
        o.on('-t', '--targets [HOST1,HOST2,HOST3]', Array,
             'List of remote hosts to provision via SSH\nProvisions locally if not specified.') do |targets|
          cli_options[:targets] = targets
        end
        o.on('-u', '--user [USER]', 'Username to use for remote provisioning') do |user|
          cli_options[:username] = user
        end
        o.separator ""
        o.separator "General options:"
        o.on_tail('-h', '--help', 'Show this message') do
          puts o
          exit
        end
      end.parse!(args)

      cli_options
    end
  end
end
