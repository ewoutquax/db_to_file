require 'simplecov'
SimpleCov.start

require 'db_to_file'
require 'pry'
require 'minitest/unit'
require 'minitest/autorun'
require "mocha/setup"
require 'turn'
require_relative 'lib/user'
require_relative 'lib/setting'
require File.expand_path('../../lib/db_to_file.rb', __FILE__)

Turn.config do |c|
  c.format  = :outline
  c.natural = true
end

drop_users      = 'drop table if exists `users`'
drop_settings   = 'drop table if exists `settings`'
create_users    = 'create table `users` (`id` integer primary key autoincrement, `name` varchar(255));'
create_settings = 'create table `settings` (`id` integer primary key autoincrement, `key` varchar(255), `value` varchar(255));'
ActiveRecord::Base.connection.execute(drop_users)
ActiveRecord::Base.connection.execute(drop_settings)
ActiveRecord::Base.connection.execute(create_users)
ActiveRecord::Base.connection.execute(create_settings)

User.delete_all
User.create(id: 1, name: 'Ewout Quax')
User.create(id: 2, name: 'Test Example')

Setting.delete_all
Setting.create(id: 1, key: 'key_1', value: 'Value_1')
Setting.create(id: 2, key: 'key_2', value: 'Value_2')
