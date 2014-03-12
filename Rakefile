require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib/db_to_file'
  t.test_files = FileList[
    'test/lib/db_to_file/**/*_test.rb'
  ]
  t.verbose = true
end

