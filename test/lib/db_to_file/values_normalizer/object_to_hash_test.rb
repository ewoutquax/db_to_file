require_relative '../../../test_helper'

describe DbToFile::ValuesNormalizer::ObjectToHash do
  describe 'normalizing' do
    let(:normalizer) {  DbToFile::ValuesNormalizer::ObjectToHash.new(@setting) }

    before do
      @setting = Setting.new(id: 1, value: ['blabla'])
    end

    it 'converts an object, to a hash with writeable values' do
      normalizer.normalize.must_equal({'id'=>'1', 'key'=>'<NULL>', 'value'=>"---\n- blabla\n"})
    end

    it 'invokes all the functions for a field' do
      normalizer.expects(:convert_nil_value)
      normalizer.expects(:convert_integer_to_string)
      normalizer.expects(:convert_yaml)

      normalizer.send(:normalize_field_value, 'bla')
    end
  end

  describe 'convert model to hash-values' do
    let(:normalizer) {  DbToFile::ValuesNormalizer::ObjectToHash.new(@setting) }

    before do
      @setting = Setting.new(id: 1, value: ['blabla'])
    end

    it 'converts integer to a string' do
      normalizer.send(:convert_integer_to_string, 1).must_equal('1')
    end

    describe 'nil conversion' do
      it 'returns <NULL> for nil' do
        normalizer.send(:convert_nil_value, nil).must_equal('<NULL>')
      end

      it 'returns original string, for all else' do
        normalizer.send(:convert_nil_value, "Test\nString\n").must_equal("Test\nString\n")
      end
    end

    describe 'convert yaml' do
      it 'returns an array as yaml' do
        normalizer.expects(:serialized_attribute?).returns(true)
        normalizer.send(:convert_yaml, ["Test\nString"]).must_equal("---\n- |-\n  Test\n  String\n")
      end

      it 'returns the original string' do
        normalizer.expects(:serialized_attribute?).returns(false)
        normalizer.send(:convert_yaml, "Test\nString").must_equal("Test\nString")
      end
    end
  end
end
