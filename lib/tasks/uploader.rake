namespace :db_to_file do
  class NoCommitMessage < Exception; end

  desc "Upload files to the database (set commit message via command 'rake db_to_file:unload['<commit message>'])"
  task :upload, [:commit_message] => :environment do |t, args|
    no_commit_message_error if args[:commit_message].blank?

    upload_files(args[:commit_message])
  end

  desc "Force uploading to the database, without checks"
  task :force_upload => :environment do |t, args|
    force_upload_files
  end

  private
    def upload_files(commit_message)
      DbToFile::Uploader.new.upload(commit_message)
    end

    def force_upload_files
      DbToFile::Uploader.new.force_upload
    end

    def no_commit_message_error
      raise NoCommitMessage, "invoke via 'rake db_to_file:unload['<commit message>']'"
    end
end
