require 'net/http'
require "net/https"
require 'json'

module GithubApiHelper
  def self.commit(api_key, user, repo, sha)
    http=Net::HTTP.new('github.com', 443)
    http.use_ssl = true
    http.start do |http|
      req = Net::HTTP::Get.new("/api/v2/json/commits/show/#{user}/#{repo}/#{sha}")
      req.basic_auth 'dpetersen/token', api_key
      response = http.request(req)
      JSON.parse(response.body)["commit"]
    end
  end
end
