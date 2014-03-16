require 'db_to_file'
require 'rails'
module DbToFile
  class Railtie < Rails::Railtie
    railtie_name :db_to_file

    rake_tasks do
      load "tasks/unloader.rake"
    end
  end
end
