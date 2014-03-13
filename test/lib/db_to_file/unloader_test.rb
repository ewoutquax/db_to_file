require_relative '../../test_helper'
require 'fileutils'

describe Unloader do
  describe 'configuration-file' do
    before do
      @unloader = Unloader.new
      @unloader.stubs(:config_file).returns('test/fixtures/config.yml')
    end

    it 'can be parsed' do
      @unloader.send(:config)['tables'].must_equal(['users', 'settings'])
    end
  end

  describe 'unloading' do
    it 'calls the functions'
  end

  describe 'build directory' do
    before do
      unloader = Unloader.new
      unloader.stub(:tables, ['users','settings']) do
        unloader.send(:unload_tables)
      end
    end

    after do
      FileUtils.rm_rf('db/db_to_unload')
    end

    it 'for the users' do
      File.directory?('db/db_to_unload/users').must_equal true
    end

    it 'for the settings' do
      File.directory?('db/db_to_unload/settings').must_equal true
    end

    it 'builds the directory for the records' do
      File.directory?('db/db_to_unload/users/1').must_equal true
      File.directory?('db/db_to_unload/users/2').must_equal true
      File.directory?('db/db_to_unload/settings/1').must_equal true
      File.directory?('db/db_to_unload/settings/2').must_equal true
    end

    it 'builds the files for the record-files' do
      File.file?('db/db_to_unload/users/1/id').must_equal true
      File.file?('db/db_to_unload/users/1/name').must_equal true
      File.file?('db/db_to_unload/settings/2/key').must_equal true
      File.file?('db/db_to_unload/settings/2/value').must_equal true

      File.read('db/db_to_unload/users/1/name').must_equal 'Ewout Quax'
      File.read('db/db_to_unload/settings/2/value').must_equal 'Value_2'
    end
  end

  it 'stashes the current changes'
  it 'git removes deleted records'
  it 'git adds new records'
  it 'git adds modified records'
  it 'git commit changes'
  it 'pops the stash'
end
