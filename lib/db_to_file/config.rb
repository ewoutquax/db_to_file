require 'singleton'

module DbToFile
  class Config
    include Singleton

    def tables
      data['tables'].keys
    end

    def field_extension(table_name, field_name)
      begin
        data['tables'][table_name]['field_extensions'][field_name]
      rescue NoMethodError
        nil
      end
    end

    def ignore_columns(table_name)
      begin
        data['tables'][table_name]['ignore_columns']
      rescue NoMethodError
        nil
      end
    end

    def directory_prefix(table_name)
      begin
        data['tables'][table_name]['directory_prefix']
      rescue NoMethodError
        nil
      end
    end

    def data
      @data ||= load_config
    end

    private
      def load_config
        YAML::load(File.read(config_file))
      end

      def config_file
        'config/db_to_file.yml'
      end
  end
end
