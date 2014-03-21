namespace :db_to_file do
  class WrongEnvironmentGiven < Exception; end

  desc 'Unload tables to file system'
  task :unload => :environment do |args|
    # wrong_environment(:environment) unless Rails.env.production?
    unload_tables
  end

  private
    def unload_tables
      DbToFile::Unloader.new.unload
    end

    def wrong_environment(environment)
      raise WrongEnvironmentGiven, "Environment should be 'production'. '#{Rails.env}' is used"
    end
end
