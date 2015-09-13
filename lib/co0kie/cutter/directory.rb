class Co0kie
  class Cutter
    class Directory
      def initialize(path, owner = nil, group = nil, mode = nil)
        @path = path
        @owner = owner
        @group = group
        @mode = mode
      end

      def create
        cmd = "if [ ! -d \"#{@path}\" ]; then sudo mkdir -p \"#{@path}\"; else echo \"Directory #{@path} exists!\"; fi"
        cmd << "; sudo chown \"#{@owner}\" \"#{@path}\"" if @owner
        cmd << "; sudo chgrp \"#{@group}\" \"#{@path}\"" if @group
        cmd << "; sudo chmod \"#{@mode}\" \"#{@path}\"" if @mode
        cmd
      end

      def delete
        "sudo rm -rf \"#{@path}\""
      end
    end
  end
end
