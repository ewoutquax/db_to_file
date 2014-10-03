require 'active_record'
require 'active_support/inflector'
require 'git'
require 'db_to_file/config'
require 'db_to_file/version'
require 'db_to_file/version_controller'
require 'db_to_file/unloader'
require 'db_to_file/uploader'
require 'db_to_file/values_normalizer/object_to_hash'
require 'db_to_file/values_normalizer/value_into_object'
require 'db_to_file/system_executer'

module DbToFile
  if defined?(Rails)
    require 'db_to_file/railtie'
  else
    dbconfig = YAML::load(File.open('db/database.yml'))
    ActiveRecord::Base.establish_connection(dbconfig)
  end
end
