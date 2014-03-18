module DbToFile
  class Unloader
    def unload
      prepare_code_version
      unload_tables
      update_code_version
    end

    private
      def prepare_code_version
        SystemExecuter.new('git stash save').execute
        SystemExecuter.new('git pull').execute
        FileUtils.rm_rf('db/db_to_file')
      end

      def unload_tables
        tables.each do |table|
          unload_table(table)
        end
      end

      def update_code_version
        update_commit_stash
        commit_changes if commitable_files_present?
        restore_stash
      end

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

      def tables
        config['tables']
      end

      def unload_table(table)
        table.singularize.capitalize.constantize.all.each do |record|
          build_directory_for_record(record)
          build_files_for_record_fields(record)
        end
      end

      def build_directory_for_record(record)
        FileUtils.mkdir_p(directory_for_record(record))
      end

      def build_files_for_record_fields(record)
        base_dir = directory_for_record(record)
        record.attributes.each do |field, value|
          file = File.join(base_dir, field)
          handle = File.open(file, 'w')
          handle.write(value)
          handle.close
        end
      end

      def directory_for_record(record)
        table = record.class.table_name
        "db/db_to_file/#{table}/#{record.id}"
      end

      def config
        @config ||= load_config
      end

      def load_config
        YAML::load(File.read(config_file))
      end

      def config_file
        'config/db_to_file.yml'
      end
  end
end
