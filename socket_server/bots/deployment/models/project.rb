class Project < ActiveRecord::Base
  validates :destination_tag_name, presence: true
  validates :clone_url, :heroku_app_name, presence: true, uniqueness: true
end
