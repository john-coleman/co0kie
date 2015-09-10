require 'net/ssh'

module Co0kie
  class Dough
    class Ssh
      def initialize(options)
        @targets = options[:targets]
        @user = options[:username] || 'root'
        @password = options[:password]
      end

      def bake(cmd)
        binding.pry
        @targets.each do |t|
          Net::SSH.start(t, @user, :password => @password) do |conn|
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

