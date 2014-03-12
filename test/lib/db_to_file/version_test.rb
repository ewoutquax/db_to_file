require_relative '../../test_helper'

describe DbToFile do
  it "must be defined" do
    DbToFile::VERSION.wont_be_nil
  end
end
