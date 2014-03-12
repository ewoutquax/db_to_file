class Unloader
  def unload
    build_directories_for_tables
  end

  private
    def build_directories_for_tables
      tables.each do |table|
        FileUtils.mkdir_p("db/db_to_unload/#{table}")
      end
    end

    def tables
      config['tables']
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
