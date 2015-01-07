module DbToFile
  class Unloader
    def initialize
      # Load config and build database connection, before stashing possible changes
      @config ||= config
      ActiveRecord::Base.connection.tables
    end

    def unload
      prepare_code_version
      unload_tables
      update_code_version
      restore_local_stash
    end

    private
      def prepare_code_version
        version_controller.prepare_code_version
      end

      def unload_tables
        puts 'Start downloading tables'
        tables.each do |table_name|
          puts "Downloading table '#{table_name}'"
          Table.new(table_name, self).unload
        end
        puts 'Done downloading tables'
      end

      def update_code_version
        puts 'Start updating code version'
        version_controller.update_code_version
        puts 'Done updating code version'
      end

      def restore_local_stash
        version_controller.restore_local_stash
      end

      def version_controller
        @version_controller ||= VersionController.new
      end

      def tables
        config.tables
      end

      def config
        Config.instance
      end

      class Table
        def initialize(table_name, unloader)
          @table    = table_name.singularize.classify.constantize
          @unloader = unloader
        end

        def unload
          @table.all.each do |row|
            Record.new(row, self).fields_to_files
          end
        end

        private
          class Record
            def initialize(row, table)
              @row   = row
              @table = table
            end

            def fields_to_files
              build_directory

              normalized_hash = DbToFile::ValuesNormalizer::ObjectToHash.new(@row).normalize
              normalized_hash.except(*ignore_columns).each_pair do |field_name, value|
                Field.new(field_name, self).write_value(value)
              end
            end

            private
              def build_directory
                FileUtils.mkdir_p(base_dir)
              end

              def ignore_columns
                config.ignore_columns(table_name)
              end

              def base_dir
                "db/db_to_file/#{table_name}/#{row_name}"
              end

              def row_name
                [directory_prefix, @row.id.to_s].compact.reject(&:empty?).join('_')
              end

              def directory_prefix
                if config_directory_prefix.present?
                  (@row.send(config_directory_prefix) || '').parameterize
                end
              end

              def config_directory_prefix
                config.directory_prefix(table_name)
              end

              def table_name
                @row.class.table_name
              end

              def config
                Config.instance
              end

              class Field
                def initialize(field_name, record)
                  @field_name = field_name
                  @record     = record
                end

                def write_value(value)
                  handle = File.open(full_file_path, 'w')
                  handle.write(value)
                  handle.close
                end

                private
                  def full_file_path
                    File.join(@record.send(:base_dir), file_with_extension)
                  end

                  def file_with_extension
                    if (extension = config_field_extension).present?
                      "#{@field_name}.#{extension}"
                    else
                      @field_name
                    end
                  end

                  def config_field_extension
                    config.field_extension(@record.send(:table_name), @field_name)
                  end

                  def config
                    Config.instance
                  end
              end
          end
      end
  end
end
