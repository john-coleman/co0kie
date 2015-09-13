class Co0kie
  class Cutter
    class File
      def initialize(path, owner = nil, group = nil, mode = nil)
        @path = path
        @owner = owner
        @group = group
        @mode = mode
      end

      def create(content)
        cmd = "/bin/echo -n '#{content}' | sudo tee '#{@path}'"
        cmd << "; sudo /bin/chown '#{@owner}' '#{@path}'" if @owner
        cmd << "; sudo /bin/chgrp '#{@group}' '#{@path}'" if @group
        cmd << "; sudo /bin/chmod '#{@mode}' '#{@path}'" if @mode
        cmd
      end

      def delete
        "sudo /bin/rm -f \"#{@path}\""
      end

      # def copy(source, dough)
      #   case dough
      #   when Co0kie::Dough::Local
      #     content = ::File.read(source)
      #     file = ::File.open(@path, 'w')
      #     file.write(content)
      #     file.chmod(@mode.to_i) if @mode
      #     file.chown(::Etc.getpwnam(@owner).uid, ::Etc.getgrnam(@group).gid) if ( @user || @group )
      #     file.close
      #     "echo 'Copied #{@source} to #{@path}'"
      #   when Co0kie::Dough::Ssh
      #     dough.targets.each do |host|
      #       binding.pry
      #       Net::SFTP.start(host, dough.user, :password => dough.password, :port => dough.port) do |conn|
      #         conn.upload!(source, @path)
      #         conn.file.chown(@path, @owner, @group) if (@owner || @group)
      #         conn.file.chmod(@path, @mode) if @mode
      #         conn.close
      #       end
      #     end
      #     "echo 'Copied #{@source} to #{@path} on #{dough.targets.join(' ')}'"
      #   else
      #     raise "This is not Dough!"
      #   end
      # end
    end
  end
end
