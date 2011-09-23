require 'net/http'
require "net/https"
require 'json'

class GithubApiHelper
  attr_reader :username, :api_key

  def initialize(username, api_key)
    @username = username
    @api_key = api_key
  end

  def commit(repository_owner, repository_name, sha)
    if repository = Repository.where(name: repository_name, owner_login: repository_owner).first
    else
      repository_object = make_request("/api/v2/json/repos/show/#{repository_owner}/#{repository_name}")["repository"]
      repository = Repository.create_from_github_json(repository_object)
    end

    if commit = Commit.where(sha: sha).first
    else
      commit_object = make_request("/api/v2/json/commits/show/#{repository_owner}/#{repository_name}/#{sha}")["commit"]
      commit = Commit.create_from_github_json(commit_object)
    end

    commit.repository = repository
    commit
  end

  def pull_requests(repository_owner, repository_name)
    pull_requests_object = make_request("/api/v2/json/pulls/#{repository_owner}/#{repository_name}")
  end

  def make_request(path)
    http = Net::HTTP.new('github.com', 443)
    http.use_ssl = true
    http.start do |http|
      req = Net::HTTP::Get.new(path)
      req.basic_auth "#{username}/token", api_key
      response = http.request(req)
      JSON.parse(response.body)
    end
  end
end
