require_relative '../../test_helper'
require 'fileutils'

describe DbToFile::Unloader do
  describe 'configuration-file' do
    before do
      @unloader = DbToFile::Unloader.new
    end

    it 'can be found' do
      @unloader.send(:config_file).must_equal('config/db_to_file.yml')
    end

    it 'can be parsed' do
      @unloader.stub(:config_file, 'test/fixtures/config.yml') do
        @unloader.send(:tables).must_equal(['users', 'settings'])
      end
    end
  end

  describe 'unloading' do
    it 'calls the functions' do
      unloader = DbToFile::Unloader.new
      unloader.expects(:prepare_code_version)
      unloader.expects(:unload_tables)
      unloader.expects(:update_code_version)

      unloader.unload
    end
  end

  describe 'build directory' do
    before do
      unloader = DbToFile::Unloader.new
      unloader.stub(:tables, ['users','settings']) do
        unloader.send(:unload_tables)
      end
    end

    after do
      FileUtils.rm_rf('db/db_to_file')
    end

    it 'for the users' do
      File.directory?('db/db_to_file/users').must_equal true
    end

    it 'for the settings' do
      File.directory?('db/db_to_file/settings').must_equal true
    end

    it 'builds the directory for the records' do
      File.directory?('db/db_to_file/users/1').must_equal true
      File.directory?('db/db_to_file/users/2').must_equal true
      File.directory?('db/db_to_file/settings/1').must_equal true
      File.directory?('db/db_to_file/settings/2').must_equal true
    end

    it 'builds the files for the record-files' do
      File.file?('db/db_to_file/users/1/id').must_equal true
      File.file?('db/db_to_file/users/1/name').must_equal true
      File.file?('db/db_to_file/settings/2/key').must_equal true
      File.file?('db/db_to_file/settings/2/value').must_equal true

      File.read('db/db_to_file/users/1/name').must_equal 'Ewout Quax'
      File.read('db/db_to_file/settings/2/value').must_equal 'Value_2'
    end
  end

  describe 'prepare code-versioning' do
    it 'invokes the system-commander' do
      executer = DbToFile::SystemExecuter.new('ls')
      executer.expects(:execute).times(2)
      DbToFile::SystemExecuter.expects(:new).with('git stash save').returns(executer)
      DbToFile::SystemExecuter.expects(:new).with('git pull').returns(executer)
      File::FileUtils.expects(:rm_rf)

      DbToFile::Unloader.new.send(:prepare_code_version)
    end
  end

  describe 'update_code_version' do
    it 'invokes all the functions' do
      executer = DbToFile::SystemExecuter.new('')
      executer.expects(:execute).times(1)
      DbToFile::SystemExecuter.expects(:new).with('git stash pop').returns(executer)

      unloader = DbToFile::Unloader.new
      unloader.expects(:update_commit_stash)
      unloader.expects(:commitable_files_present?).returns(true)
      unloader.expects(:commit_changes)

      unloader.send(:update_code_version)
    end

    describe 'update commit_stash' do
      before do
        DbToFile::Unloader.new.send(:unload_table, 'users')
      end

      after do
        FileUtils.rm_rf('db/db_to_file')
      end

      it 'git adds new records' do
        executer = DbToFile::SystemExecuter.new('')
        executer.expects(:execute).times(4)

        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/1/id').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/1/name').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/2/id').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/2/name').returns(executer)

        DbToFile::Unloader.new.send(:update_commit_stash)
      end

      it 'git removes deleted records'
      it 'git adds modified records'
    end

    it 'git commit changes' do
      git = Minitest::Mock.new

      unloader = DbToFile::Unloader.new
      unloader.expects(:git).returns(git)

      git.expect(:commit, nil, ['Customer changes'])
      unloader.send(:commit_changes)
      git.verify
    end

    it 'restores the stash' do
      executer = DbToFile::SystemExecuter.new('')
      executer.expects(:execute).times(1)
      DbToFile::SystemExecuter.expects(:new).with('git stash pop').returns(executer)

      DbToFile::Unloader.new.send(:restore_stash)
    end
  end
end
