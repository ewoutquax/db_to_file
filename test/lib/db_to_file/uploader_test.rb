require_relative '../../test_helper'
require 'fileutils'

describe DbToFile::Uploader do
  it 'invokes all the functions' do
    uploader = DbToFile::Uploader.new
    uploader.expects(:build_objects)

    uploader.upload
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
      models.first.class.must_equal(User)
      models.last.class.must_equal(User)

      user_1 = models.detect{|m| m.id == 1}
      user_2 = models.detect{|m| m.id == 2}
      user_1.name.must_equal 'Ewout Quax'
      user_2.name.must_equal 'Test Example'
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
