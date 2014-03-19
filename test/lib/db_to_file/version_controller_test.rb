require_relative '../../test_helper'
require 'fileutils'

describe DbToFile::VersionController do
  describe 'unloading' do
    it 'calls the functions' do
      unloader = DbToFile::Unloader.new
      unloader.expects(:prepare_code_version)
      unloader.expects(:unload_tables)
      unloader.expects(:update_code_version)

      unloader.unload
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

      controller = DbToFile::VersionController.new
      controller.expects(:update_commit_stash)
      controller.expects(:commitable_files_present?).returns(true)
      controller.expects(:commit_changes)

      controller.send(:update_code_version)
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

        DbToFile::VersionController.new.send(:update_commit_stash)
      end

      it 'git removes deleted records'
      it 'git adds modified records'
    end

    it 'git commit changes' do
      git = Minitest::Mock.new

      controller = DbToFile::VersionController.new
      controller.expects(:git).returns(git)

      git.expect(:commit, nil, ['Customer changes'])
      controller.send(:commit_changes)
      git.verify
    end

    it 'restores the stash' do
      executer = DbToFile::SystemExecuter.new('')
      executer.expects(:execute).times(1)
      DbToFile::SystemExecuter.expects(:new).with('git stash pop').returns(executer)

      DbToFile::VersionController.new.send(:restore_stash)
    end
  end
end
