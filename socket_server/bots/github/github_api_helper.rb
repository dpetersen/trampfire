require 'net/http'
require "net/https"
require 'json'

class GithubApiHelper
  attr_reader :username, :api_key

  def initialize(username, api_key)
    @username = username
    @api_key = api_key
  end

  def commit(user, repo, sha)
    make_request("/api/v2/json/commits/show/#{user}/#{repo}/#{sha}")["commit"]
  end

  def repo(user, repo)
    make_request("/api/v2/json/repos/show/#{user}/#{repo}")["repository"]
  end

  def user(user)
    make_request("/api/v2/json/user/show/#{user}")["user"]
  end

  protected

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
