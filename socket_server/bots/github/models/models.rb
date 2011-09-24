require 'active_record'

ActiveRecord::Base.include_root_in_json = false

require_relative 'commit'
require_relative 'repository'
require_relative 'repository_watch'
require_relative 'pull_request'
