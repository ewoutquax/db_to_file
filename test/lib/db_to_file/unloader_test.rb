require_relative '../../test_helper'

describe Unloader do
  describe 'configuration-file' do
    it 'can be parsed' do
      @unloader = Unloader.new
      @unloader.stubs(:config_file).returns('test/fixtures/config.yml')

      Unloader.stub(:new, @unloader) do
        Unloader.new.config['tables'].must_equal(['users', 'settings'])
      end
    end
  end
  it 'builds the directory for the tables'
  it 'builds the directory for the records'
  it 'builds the files for the record-files'
  it 'stashes the current changes'
  it 'pops the stash'
end
