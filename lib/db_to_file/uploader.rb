module DbToFile
  class Uploader
    def upload(commit_message)
      if can_continue?
        invoke_unloader
      end
      if can_continue?
        write_objects_to_db
        update_code_version(commit_message)
      end
    end

    def force_upload
      write_objects_to_db
    end

    private
      def invoke_unloader
        Unloader.new.unload
      end

      def can_continue?
        !merge_conflicts_present?
      end

      def merge_conflicts_present?
        version_controller.merge_conflicts_present?
      end

      def write_objects_to_db
        objects.each(&:save!)
      end

      def update_code_version(commit_message)
        version_controller.update_code_version(commit_message)
      end

      def objects
        @objects ||= build_objects
      end

      def build_objects
        objects = []
        read_files.each do |model_field_file|
          data_segments = extract_data_segments(model_field_file)
          model = data_segments[:model]
          # find existing object
          object = objects.detect do |existing_object|
            existing_object.class == model && existing_object.id == data_segments[:id]
          end
          # build new object
          unless object
            object = model.find(data_segments[:id])
            objects << object
          end
          # set field-value to model
          update_object_with_field_value(object, data_segments[:field], model_field_file)
        end

        objects
      end

      def update_object_with_field_value(object, field, model_field_file)
        value = file_value(model_field_file)
        DbToFile::ValuesNormalizer::ValueIntoObject.new(object).normalize(field, value)
      end

      def file_value(model_field_file)
        File.read(model_field_file)
      end

      def extract_data_segments(model_field_file)
        matches = model_field_file.split('/').last(3)

        {
          model: matches[0].singularize.classify.constantize,
          id: matches[1].split('_').last.to_i,
          field: matches[2]
        }
      end

      def read_files
        files_in_dir(File.join('db', 'db_to_file'))
      end

      def files_in_dir(folder)
        files = Dir.entries(folder)

        found_files = []
        files.each do |file|
          full_file = File.join([folder, file])
          if File.directory?(full_file) && file[0] != '.'
            subdir = File.join(folder, file)
            files_in_dir(subdir).each do |subdirfile|
              found_files << subdirfile
            end
          end
          if File.file?(full_file)
            found_files << full_file
          end
        end

        found_files
      end

      def version_controller
        @version_controller ||= VersionController.new
      end
  end
end
