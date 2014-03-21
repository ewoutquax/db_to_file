module DbToFile
  class Unloader
    def unload
      prepare_code_version
      unload_tables
      update_code_version
      restore_local_stash
    end

    private
      def prepare_code_version
        version_controller.prepare_code_version
      end

      def unload_tables
        puts 'Start downloading tables'
        tables.each do |table|
          puts "Downloading table #{table}"
          unload_table(table)
        end
        puts 'Done downloading tables'
      end

      def update_code_version
        puts 'Start updating code version'
        version_controller.update_code_version
        puts 'Done updating code version'
      end

      def restore_local_stash
        version_controller.restore_local_stash
      end

      def version_controller
        @version_controller ||= VersionController.new
      end

      def tables
        config['tables'].keys
      end

      def unload_table(table)
        table.singularize.classify.constantize.all.each do |record|
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
        "db/db_to_file/#{table}/#{row_name(record)}"
      end

      def row_name(record)
        table = record.class.table_name
        row_name = nil
        row_name = "#{record.send(config['tables'][table]['directory_prefix']).parameterize}" if config['tables'][table].present?
        [row_name, record.id.to_s].compact.reject(&:empty?).join('_')
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
