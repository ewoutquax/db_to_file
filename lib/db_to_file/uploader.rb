module DbToFile
  class Uploader
    def upload
      build_objects
    end

    private
      def build_objects
        objects = []
        read_files.each do |model_field_file|
          # break up file-path in 3 segments: model, id, field
          matches = model_field_file.scan(/\/([a-z]+)\/(\d+)\/([a-z_]+)/).flatten
          # determine model-class
          model = matches.first.singularize.capitalize.constantize
          # find existing object
          object = objects.detect do |existing_object|
            existing_object.class == model && existing_object.id == matches[1].to_i
          end
          # build new object
          unless object
            object = model.new
            object.id = matches[1].to_i
            objects << object
          end
          # set field-value to model
          value = File.read(model_field_file)
          object.send("#{matches[2]}=", value)
        end

        objects
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
  end
end