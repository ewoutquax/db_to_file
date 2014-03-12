class Unloader
  attr_reader :config
  def config
    @config ||= load_config
  end

  private
    def load_config
      YAML::load(File.read(config_file))
    end

    def config_file
      'config/db_to_file.yml'
    end
end
