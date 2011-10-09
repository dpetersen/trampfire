class Project < ActiveRecord::Base
  validates :clone_url, :heroku_app_name, presence: true
end
