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
        unloader.send(:build_directories_for_tables)
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

    it 'builds the files for the record-files'
  end

  it 'stashes the current changes'
  it 'pops the stash'
end
