require_relative '../../test_helper'
require 'fileutils'

describe DbToFile::Unloader do
  let(:unloader) { DbToFile::Unloader.new }

  before do
    DbToFile::Config.any_instance.stubs(:config_file).returns('test/fixtures/config.yml')
  end

  describe 'configuration-file' do
    it 'can be parsed' do
      unloader.send(:tables).must_equal(['users', 'settings'])
    end

    it 'can read directory prefix' do
      @table  = DbToFile::Unloader::Table.new('users', @unloader)
      @record = DbToFile::Unloader::Table::Record.new(User.first, @table)

      @record.send(:config_directory_prefix).must_equal('name')

      @table  = DbToFile::Unloader::Table.new('settings', @unloader)
      @record = DbToFile::Unloader::Table::Record.new(Setting.first, @table)

      @record.send(:config_directory_prefix).must_equal(nil)
    end

    it 'can read file-extensions' do
      @table      = DbToFile::Unloader::Table.new('users', @unloader)
      @record     = DbToFile::Unloader::Table::Record.new(User.first, @table)
      @field_name = DbToFile::Unloader::Table::Record::Field.new('name', @record)
      @field_id   = DbToFile::Unloader::Table::Record::Field.new('id', @record)

      DbToFile::Config.instance.stub(:config_file, 'test/fixtures/config.yml') do
        @field_name.send(:config_field_extension).must_equal('txt')
        @field_id.send(:config_field_extension).must_equal(nil)
      end
    end
  end

  describe 'unloading' do
    it 'calls the functions' do
      unloader.expects(:prepare_code_version)
      unloader.expects(:unload_tables)
      unloader.expects(:update_code_version)
      unloader.expects(:restore_local_stash)

      unloader.unload
    end
  end

  describe 'build directory for users with prefix' do
    before do
      unloader.stubs(:config_directory_prefix).returns('name')
      DbToFile::Config.instance.stub(:config_file, 'test/fixtures/config.yml') do
        unloader.stub(:tables, ['users']) do
          unloader.send(:unload_tables)
        end
      end
    end

    after do
      FileUtils.rm_rf('db/db_to_file')
    end

    it 'for the users' do
      File.directory?('db/db_to_file/users').must_equal true
    end

    it 'builds the directory for the records' do
      File.directory?('db/db_to_file/users/ewout-quax_1').must_equal true
      File.directory?('db/db_to_file/users/test-example_2').must_equal true
      File.directory?('db/db_to_file/users/3').must_equal true
    end

    it 'builds the files for the record-files' do
      File.file?('db/db_to_file/users/ewout-quax_1/id').must_equal true
      File.file?('db/db_to_file/users/ewout-quax_1/name.txt').must_equal true

      File.read('db/db_to_file/users/ewout-quax_1/name.txt').must_equal "Ewout Quax\n"
    end
  end

  describe 'build directory for users without prefix' do
    before do
      unloader.stubs(:config_directory_prefix).returns(nil)
      unloader.stubs(:config_ignore_columns).returns(nil)
      unloader.stubs(:config_field_extension).returns(nil)
      unloader.stub(:tables, ['settings']) do
        unloader.send(:unload_tables)
      end
    end

    after do
      FileUtils.rm_rf('db/db_to_file')
    end

    it 'for the settings' do
      File.directory?('db/db_to_file/settings').must_equal true
    end

    it 'builds the directory for the records' do
      File.directory?('db/db_to_file/settings/1').must_equal true
      File.directory?('db/db_to_file/settings/2').must_equal true
    end

    it 'builds the files for the record-files' do
      File.file?('db/db_to_file/settings/2/key').must_equal true
      File.file?('db/db_to_file/settings/2/value').must_equal true

      File.read('db/db_to_file/settings/2/value').must_equal "<NULL>\n"
    end
  end

  describe 'prepare code-versioning' do
    it 'invokes the version-controller' do
      controller = Minitest::Mock.new
      DbToFile::VersionController.expects(:new).returns(controller)

      controller.expect(:prepare_code_version, nil)
      unloader.send(:prepare_code_version)
      controller.verify
    end
  end

  describe 'update_code_version' do
    it 'invokes all the functions' do
      controller = Minitest::Mock.new

      unloader.expects(:version_controller).returns(controller)

      controller.expect(:update_code_version, nil)
      unloader.send(:update_code_version)
      controller.verify
    end
  end
end
