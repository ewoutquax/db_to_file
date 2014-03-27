require_relative '../../../test_helper'

describe DbToFile::ValuesNormalizer::ValueIntoObject do
  describe 'normalizing' do
    let(:normalizer) {  DbToFile::ValuesNormalizer::ValueIntoObject.new(Setting) }

    before do
      @hash = {id: '1', key: '<NULL>', value: "---\n- blabla\n"}
    end

    it 'invokes all the functions for a field' do
      normalizer.expects(:convert_yaml)
      normalizer.expects(:strip_trailing_newline)
      normalizer.expects(:convert_nil_value)

      normalizer.send(:normalize_field_value, 'value', 'bla')
    end
  end

  describe 'convert hash-values to object-values' do
    let(:normalizer) {  DbToFile::ValuesNormalizer::ValueIntoObject.new(Setting) }

    describe 'nil conversion' do
      it 'returns nil for <NULL>' do
        normalizer.send(:convert_nil_value, '<NULL>').must_equal(nil)
      end

      it 'returns empty string for an empty string' do
        normalizer.send(:convert_nil_value, '').must_equal('')
      end

      it 'returns original string, for all else' do
        normalizer.send(:convert_nil_value, "Test\nString\n").must_equal("Test\nString\n")
      end
    end

    describe 'trailing newline' do
      it 'strips when present' do
        normalizer.send(:strip_trailing_newline, "Test\nString\n").must_equal("Test\nString")
      end

      it 'return original string, when not present' do
        normalizer.send(:strip_trailing_newline, "Test\nString").must_equal("Test\nString")
      end

      it 'return original string, when not present' do
        normalizer.send(:strip_trailing_newline, "Test\nString").must_equal("Test\nString")
      end
    end

    describe 'convert yaml' do
      it 'returns an array as yaml' do
        normalizer.expects(:serialized_attribute?).returns(true)
        normalizer.send(:convert_yaml, "---\n- |-\n  Test\n  String\n").must_equal(["Test\nString"])
      end

      it 'returns the original string' do
        normalizer.expects(:serialized_attribute?).returns(false)
        normalizer.send(:convert_yaml, "Test\nString").must_equal("Test\nString")
      end
    end
  end
end
