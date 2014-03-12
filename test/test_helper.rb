require 'db_to_file'
require 'pry'
require 'minitest/unit'
require 'minitest/autorun'
require "mocha/setup"
require 'active_record'
require File.expand_path('../../lib/db_to_file.rb', __FILE__)

dbconfig = YAML::load(File.open('db/database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
