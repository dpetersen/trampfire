class Repository < ActiveRecord::Base
  validates :name, :url, :owner_login, presence: true

  def self.create_from_github_json(attributes)
    create!(
      name: attributes["name"],
      url: attributes["url"],
      owner_login: attributes["owner"]
    )
  end

  def owner_path
    "http://github.com/#{@owner_login}"
  end
end
