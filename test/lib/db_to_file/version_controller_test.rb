require_relative '../../test_helper'
require 'fileutils'

describe DbToFile::VersionController do
  describe 'prepare code-versioning' do
    it 'invokes the system-commander' do
      executer = DbToFile::SystemExecuter.new('ls')
      executer.expects(:execute).times(2)
      DbToFile::SystemExecuter.expects(:new).with("git stash save 'db-to-file'").returns(executer)
      DbToFile::SystemExecuter.expects(:new).with('git pull').returns(executer)
      File::FileUtils.expects(:rm_rf)

      unloader = instantiate_unloader
      unloader.send(:prepare_code_version)
    end
  end

  describe 'update_code_version' do
    it 'invokes all the functions' do
      controller = DbToFile::VersionController.new
      controller.expects(:update_commit_stash)
      controller.expects(:commitable_files_present?).returns(true)
      controller.expects(:commit_changes)

      controller.send(:update_code_version)
    end

    describe 'update commit_stash' do
      before do
        write_file('db/db_to_file/users/ewout-quax_1', 'id', '1')
        write_file('db/db_to_file/users/ewout-quax_1', 'name', 'Ewout Quax')
        write_file('db/db_to_file/users/test-example_2', 'id', '2')
        write_file('db/db_to_file/users/test-example_2', 'name', 'Test Example')
      end

      after do
        FileUtils.rm_rf('db/db_to_file')
      end

      it 'git adds new records' do
        executer = DbToFile::SystemExecuter.new('')
        executer.expects(:execute).times(5)
        DbToFile::SystemExecuter.expects(:new).with('git status --porcelain').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/ewout-quax_1/id').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/ewout-quax_1/name').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/test-example_2/id').returns(executer)
        DbToFile::SystemExecuter.expects(:new).with('git add db/db_to_file/users/test-example_2/name').returns(executer)

        DbToFile::VersionController.new.send(:update_commit_stash)
      end
    end

    describe 'git commit changes' do
      let(:git) { Minitest::Mock.new }
      let(:controller) { DbToFile::VersionController.new }

      it 'with custom commit message' do
        controller.expects(:git).returns(git)

        git.expect(:commit, nil, ['custom commit message'])
        controller.send(:commit_changes, 'custom commit message')
        git.verify
      end

      it 'with default commit message' do
        controller.expects(:git).returns(git)

        git.expect(:commit, nil, ['DbToFile: changes by customer'])
        controller.send(:commit_changes, nil)
        git.verify
      end
    end

    it 'restores the stash' do
      executer = DbToFile::SystemExecuter.new('')
      executer.expects(:execute).times(1)
      DbToFile::SystemExecuter.expects(:new).with('git stash pop').returns(executer)

      DbToFile::VersionController.new.send(:restore_stash)
    end
  end

  describe 'restore_local_stash' do
    it 'invokes all the functions' do
      controller = DbToFile::VersionController.new
      controller.expects(:restore_stash)

      controller.send(:restore_local_stash)
    end

    describe 'restore_stash' do
      it 'invokes the correct command' do
        executer = DbToFile::SystemExecuter.new('')
        executer.expects(:execute).times(1)
        DbToFile::SystemExecuter.expects(:new).with('git stash pop').returns(executer)

        controller = DbToFile::VersionController.new
        controller.send(:restore_stash)
      end
    end
  end

  describe 'merge_conflicts_present' do
    let(:controller) { DbToFile::VersionController.new }
    let(:executer) { Minitest::Mock.new }

    before do
      @output_without_merge_error = 'M  test/lib/db_to_file/uploader_test.rb'
      @output_with_merge_error = 'U  test/lib/db_to_file/uploader_test.rb'
    end

    it 'return true, when merge-errors are found' do
      DbToFile::SystemExecuter.expects(:new).with('git status --porcelain').returns(executer)

      executer.expect(:execute, @output_with_merge_error)
      controller.merge_conflicts_present?.must_equal(true)
    end


    it 'return false, when merge-errors are absent' do
      DbToFile::SystemExecuter.expects(:new).with('git status --porcelain').returns(executer)

      executer.expect(:execute, @output_without_merge_error)
      controller.merge_conflicts_present?.must_equal(false)
    end
  end

  def instantiate_unloader
    DbToFile::Config.any_instance.stubs(:config_file).returns('test/fixtures/config.yml')
    DbToFile::Unloader.new
  end
end
