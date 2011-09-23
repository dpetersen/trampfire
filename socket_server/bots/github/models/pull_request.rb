class PullRequest < ActiveRecord::Base
  validates :owner_login, :repository_name, :pull_request_number, presence: true
end
