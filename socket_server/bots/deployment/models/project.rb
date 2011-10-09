class Project < ActiveRecord::Base
  validates :destination_tag_name, presence: true
  validates :clone_url, :heroku_app_name, presence: true, uniqueness: true

  def path
    File.join(DeploymentBot::REPO_STORAGE_PATH, self.id.to_s)
  end
end
