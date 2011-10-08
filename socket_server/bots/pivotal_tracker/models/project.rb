class Project < ActiveRecord::Base
  validates :project_id, :destination_tag_name, presence: true
  validates :project_id, uniqueness: true
end
