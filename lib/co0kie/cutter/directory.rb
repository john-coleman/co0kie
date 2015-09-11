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
        cmd = "if [ ! -d \"#{@path}\" ]; then mkdir \"#{@path}\"; else echo \"Directory #{@path} exists!\"; fi"
        cmd << "; chown \"#{@owner}\" \"#{@path}\"" if @owner
        cmd << "; chgrp \"#{@group}\" \"#{@path}\"" if @group
        cmd << "; chmod \"#{@mode}\" \"#{@path}\"" if @mode
        cmd
      end

      def delete
        "rm -rf \"#{@path}\""
      end
    end
  end
end
