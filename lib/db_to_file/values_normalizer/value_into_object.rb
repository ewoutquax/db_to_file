module DbToFile
  module ValuesNormalizer
    class ValueIntoObject
      def initialize(object)
        @object = object
      end

      def normalize(fieldname, value)
        if @object.respond_to?(fieldname.to_sym)
          normalized_value = normalize_field_value(fieldname, value)
          @object.send("#{fieldname}=", normalized_value)
        end
      end

      private
        def normalize_field_value(fieldname, value)
          @current_field = fieldname
          value = strip_trailing_newline(value)
          value = convert_nil_value(value)
          value = convert_yaml(value)
        end

        def strip_trailing_newline(text)
          (text[-1] == "\n") ? text[0..-2] : text
        end

        def convert_nil_value(value)
          (value == '<NULL>') ? nil : value
        end

        def convert_yaml(value)
          (!value.nil? && serialized_attribute?(@current_field)) ? YAML.load(value) : value
        end

        def serialized_attribute?(field)
          @object.class.serialized_attributes.keys.include?(field.to_s)
        end
    end
  end
end
