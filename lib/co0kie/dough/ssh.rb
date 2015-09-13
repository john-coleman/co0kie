class Co0kie
  class Dough
    class Ssh
      attr_reader :password
      attr_reader :port
      attr_reader :targets
      attr_reader :user

      def initialize(options)
        @password = options[:password]
        @port = options[:port]
        @targets = options[:targets]
        @user = options[:username] || 'root'
      end

      def bake(cmd)
        @targets.each do |t|
          Net::SSH.start(t, @user, :password => @password, :port => @port) do |conn|
            output = { stdout: '', stderr: '' }
            conn.exec!(cmd) do |channel, stream, data|
              output[stream] << data
              puts "#{t}: #{data}"
            end
            output
          end
        end
      end
    end
  end
end

