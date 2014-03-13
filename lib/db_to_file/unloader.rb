class Unloader
  def unload
    prepare_code_version
    unload_tables
  end

  private
    def prepare_code_version
      SystemExecuter.new('git stash save').execute
      SystemExecuter.new('git pull').execute
    end

    def tables
      config['tables']
    end

    def unload_tables
      tables.each do |table|
        unload_table(table)
      end
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
      "db/db_to_unload/#{table}/#{record.id}"
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
