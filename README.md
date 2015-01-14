*!This Readme is work-in-progress!*

# DbToFile

Download selected tables of your database to editable files, and load them back up.
Files that are changed during down- or uploading, are commited into version-control (only Git is supported)

## Installation

Add this line to your application's Gemfile:

    gem 'db_to_file'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install db_to_file

## Usage

All commands are shown with `rake -T`

#### unload
`rake db_to_file:unload` *Unload tables to file system*

#### upload
`rake db_to_file:upload[commit_message]` *Upload files to the database (set commit message via command 'rake db_to_file:upload['<commit message\>'])*

Upload will halt, when no commit-message has been given.

#### force-upload
`rake db_to_file:force_upload` *Force uploading to the database, without checks*

#### force_changed
`rake db_to_file:force_changed` *Force uploading only changed files in database, without checks*

### Configuration

In the configuration the tables to be unloaded are set.
Each given table will result into a subdirectory, and all rows of that table will become a sub-subdirectory. Within the sub-subdirectory there will be a file for each field of the row.

#### Row prefix

Per table a field can be set that will be used as prefix for the row-directory. This will help identifing the correct row, when looking for a specific record.

#### File extension

When a field contains HTML (or another format identifiable by a file-extension), you can set that file to always have that extension.
During unload, each file will be appended with the given suffix.
That suffix will be removed during the upload process. 

## End result
The unloaded directory is placed in /db/db_to_file and looks like this:

    \ db_to_file
      \ settings
      | \ 1
      | | - id
      | | - key
      | | - value
      | \ 2
      |   - id
      |   - key
      |   - value
      \ users
        \ 3
        | - id
        | - name.txt
        \ a-nonymous_1
        | - id
        | - name.txt
        \ test-example_2
          - id
          - name.txt

## Contributing

1. Fork it ( http://github.com/<my-github-username>/db_to_file/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
