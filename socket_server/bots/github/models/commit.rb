require 'digest/md5'

class Commit < ActiveRecord::Base
  validates :sha, :url, :message, :author_email, :author_name, presence: true
  validates :sha, uniqueness: true

  attr_accessor :repository

  def self.create_from_github_json(attributes)
    create!(
      sha: attributes["id"],
      url: attributes["url"],
      message: attributes["message"],
      author_email: attributes["author"]["email"],
      author_login: attributes["author"]["login"],
      author_name: attributes["author"]["name"]
    )
  end

  def url
    "http://github.com#{@url}"
  end

  def authored_by_github_user?
    author_login.present?
  end

  def author_profile_path
    "http://github.com/#{author_login}"
  end

  def author_gravatar_url
    md5 = Digest::MD5.hexdigest(author_email)
    "http://gravatar.com/avatar/#{md5}"
  end
end
