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
        cmd = "echo -n \"#{content}\" > \"#{@path}\""
        cmd << "; chown \"#{@owner}\" \"#{@path}\"" if @owner
        cmd << "; chgrp \"#{@group}\" \"#{@path}\"" if @group
        cmd << "; chmod \"#{@mode}\" \"#{@path}\"" if @mode
        cmd
      end

      def delete
        "rm -f \"#{@path}\""
      end
    end
  end
end
