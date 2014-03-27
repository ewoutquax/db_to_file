module DbToFile
  module ValuesNormalizer
    class ObjectToHash
      def initialize(object)
        @object = object
      end

      def normalize
        @hash = {}
        @object.attributes.each do |field, value|
          @current_field = field
          @hash[field] = normalize_field_value(value)
        end
        @hash
      end

      private
        def normalize_field_value(value)
          value = convert_yaml(value)
          value = convert_nil_value(value)
          value = convert_integer_to_string(value)
        end

        def convert_yaml(value)
          (!value.nil? && serialized_attribute?(@current_field)) ? value.to_yaml : value
        end

        def serialized_attribute?(field)
          @object.class.serialized_attributes.keys.include?(field.to_s)
        end


        def convert_nil_value(value)
          (value.nil?) ? '<NULL>' : value
        end
        def convert_integer_to_string(integer)
          "#{integer}"
        end
    end
  end
end
