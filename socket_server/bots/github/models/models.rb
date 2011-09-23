ActiveRecord::Base.include_root_in_json = false

require File.join(File.dirname(__FILE__), 'commit')
require File.join(File.dirname(__FILE__), 'repository')
require File.join(File.dirname(__FILE__), 'repository_watch')
