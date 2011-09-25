ActiveRecord::Base.include_root_in_json = false

require File.join(File.dirname(__FILE__), 'user')
require File.join(File.dirname(__FILE__), 'tag')
require File.join(File.dirname(__FILE__), 'message')
require File.join(File.dirname(__FILE__), 'tab')
require File.join(File.dirname(__FILE__), 'tag_assignment')
