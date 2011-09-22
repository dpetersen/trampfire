class RepositoryWatch < ActiveRecord::Base
  validates :owner_login, :repository_name, :destination_tag_name, presence: true
  validates :repository_name, uniqueness: { scope: :owner_login }
end
