require 'active_record'
require 'active_support/inflector'
require 'git'
require 'db_to_file/version'
require 'db_to_file/version_controller'
require 'db_to_file/unloader'
require 'db_to_file/uploader'
require 'db_to_file/system_executer'

module DbToFile
  if defined?(Rails)
    require 'db_to_file/railtie'
    dbconfig = YAML::load(File.open("#{Dir.pwd}/config/database.yml"))[Rails.env]
  else
    dbconfig = YAML::load(File.open('db/database.yml'))
  end
  ActiveRecord::Base.establish_connection(dbconfig)
end
