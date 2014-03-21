require_relative '../../test_helper'
require 'fileutils'

describe DbToFile::Uploader do
  it 'invokes all the functions' do
    uploader = DbToFile::Uploader.new

    uploader.expects(:can_continue?).returns(true).times(2)
    uploader.expects(:invoke_unloader)
    uploader.expects(:write_objects_to_db)
    uploader.expects(:update_code_version)

    uploader.upload('uploader_test')
  end

  describe 'can_continue' do
    let(:uploader) { DbToFile::Uploader.new }

    it 'return false, if merge conflicts are found' do
      uploader.stub(:merge_conflicts_present?, true) do
        uploader.send(:can_continue?).must_equal(false)
      end
    end

    it 'return true, if no merge conflicts are found' do
      uploader.stub(:merge_conflicts_present?, false) do
        uploader.send(:can_continue?).must_equal(true)
      end
    end
  end

  describe 'merge_conflicts_present' do
    let(:uploader) { DbToFile::Uploader.new }
    let(:controller) { Minitest::Mock.new }

    it 'invokes the version controller' do
      controller.expect(:merge_conflicts_present?, true)
      uploader.stub(:version_controller, controller) do
        uploader.send(:merge_conflicts_present?).must_equal(true)
      end
      controller.verify
    end
  end

  describe 'objects' do
    after do
      User.last.delete
    end

    it 'are saved to the db' do
      user_1 = User.new(name: 'Test UserName')
      uploader = DbToFile::Uploader.new
      uploader.expects(:build_objects).returns([user_1])

      uploader.send(:write_objects_to_db)

      User.last.must_equal(user_1)
    end
  end

  describe 'unloaded files' do
    before do
      write_file('db/db_to_file/users/1', 'id', '1')
      write_file('db/db_to_file/users/1', 'name', 'Ewout Quax')
      write_file('db/db_to_file/users/2', 'id', '2')
      write_file('db/db_to_file/users/2', 'name', 'Test Example')
    end

    after do
      FileUtils.rm_rf('db/db_to_file')
    end

    it 'can be read' do
      files = DbToFile::Uploader.new.send(:read_files)
      files.include?('db/db_to_file/users/1/id').must_equal true
      files.include?('db/db_to_file/users/1/name').must_equal true
      files.include?('db/db_to_file/users/2/id').must_equal true
      files.include?('db/db_to_file/users/2/name').must_equal true
    end

    it 'can be builded into models' do
      models = DbToFile::Uploader.new.send(:build_objects)
      models.size.must_equal 2
      models.first.class.must_equal(User)
      models.last.class.must_equal(User)

      user_1 = models.detect{|m| m.id == 1}
      user_2 = models.detect{|m| m.id == 2}
      user_1.name.must_equal 'Ewout Quax'
      user_2.name.must_equal 'Test Example'
    end
  end

  describe 'update_code_version' do
    let(:uploader) { DbToFile::Uploader.new }
    let(:controller) { Minitest::Mock.new }

    it 'invokes the version-controller, with a commit message' do
      uploader.expects(:version_controller).returns(controller)

      controller.expect(:update_code_version, true, ['commit via test'])
      uploader.send(:update_code_version, 'commit via test')
      controller.verify
    end
  end
end

def write_file(dir, file, value)
  FileUtils.mkdir_p(dir)
  full_file = File.join(dir, file)

  handle = File.open(full_file, 'w')
  handle.write(value)
  handle.close
end
