module DbToFile
  class VersionController
    def prepare_code_version
      SystemExecuter.new('git stash save').execute
      SystemExecuter.new('git pull').execute
      FileUtils.rm_rf('db/db_to_file')
    end

    def update_code_version
      update_commit_stash
      commit_changes if commitable_files_present?
      restore_stash
    end

    private
      def update_commit_stash
        new_files.each do |file|
          SystemExecuter.new("git add #{file}").execute if table_file?(file)
        end
        modified_files.each do |file|
          SystemExecuter.new("git add #{file}").execute if table_file?(file)
        end
        deleted_files.each do |file|
          SystemExecuter.new("git rm #{file}").execute if table_file?(file)
        end
      end

      def commitable_files_present?
        out = SystemExecuter.new('git status --porcelain')
        out.split("\n").reject{|line| [' ', '?'].include?(line[0])}.any?
      end

      def commit_changes
        git.commit('Customer changes')
      end

      def restore_stash
        SystemExecuter.new('git stash pop').execute
      end

      def new_files
        git.status.untracked.map{|file, git_object| file}
      end

      def modified_files
        git.status.changed.map{|file, git_object| file}
      end

      def deleted_files
        git.status.deleted.map{|file, git_object| file}
      end

      def table_file?(file)
        file.index('db/db_to_file') === 0
      end

      def git
        @git ||= Git.open(Dir.pwd)
      end
  end
end
