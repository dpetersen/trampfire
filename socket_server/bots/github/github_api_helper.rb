require 'net/http'
require "net/https"
require 'digest/md5'
require 'json'

module GithubBotz
  # Why Author and not User?  Because making another API call to get
  # User info isn't all that helpful.  I won't display anything from it.
  class Author
    attr_reader :name

    def initialize(o)
      @login = o["login"]
      @email = o["email"]
      @name = o["name"]
    end

    def is_github_user?
      @login.present?
    end

    def profile_path
      "http://github.com/#{@login}"
    end

    def gravatar_url
      md5 = Digest::MD5.hexdigest(@email)
      "http://gravatar.com/avatar/#{md5}"
    end
  end

  # {
  #   "description"=>"",
  #   "forks"=>0,
  #   "has_issues"=>true,
  #   "created_at"=>"2009/09/14 10:41:08 -0700",
  #   "language"=>"Ruby",
  #   "homepage"=>"",
  #   "has_downloads"=>true,
  #   "organization"=>"factorylabs",
  #   "fork"=>false,
  #   "watchers"=>1,
  #   "size"=>422932,
  #   "private"=>true,
  #   "name"=>"revo",
  #   "owner"=>"factorylabs",
  #   "has_wiki"=>true,
  #   "pushed_at"=>"2011/09/19 18:41:11 -0700",
  #   "open_issues"=>0,
  #   "url"=>"https://github.com/factorylabs/revo"
  # }
  class Repository
    attr_reader :name, :url, :owner_login

    def initialize(o)
      @name = o["name"]
      @url = o["url"]
      @owner_login = o["owner"]
    end

    def owner_path
      "http://github.com/#{@owner_login}"
    end
  end

  # {
  #   "modified"  =>  [
  #     {
  #       "diff"      =>"diff here",
  #       "filename"      =>"models/message.rb"
  #     }
  #   ],
  #   "parents"  =>  [
  #     {
  #       "id"      =>"7c996d672393bb5a1b21fb4afbc332ef8a16673d"
  #     }
  #   ],
  #   "author"  =>  {
  #     "name"    =>"Don Petersen",
  #     "login"    =>"",
  #     "email"    =>"don.petersen@factorylabs.com"
  #   },
  #   "url"  =>"/dpetersen/trampfire/commit/7ce73bd45364d97eb93b89dbe7e019c08b541d09",
  #   "id"  =>"7ce73bd45364d97eb93b89dbe7e019c08b541d09",
  #   "committed_date"  =>"2011-09-19T17:02:44-07:00,
  #   "authored_date"=>"2011-09-19T16:34:13-07:00  ", 
  #   "message"=> "Strip messages of whitespace before processing.",
  #   "tree"  =>"8da591223f7cf3bf788293e3d88261cda0bdcdb7",
  #   "committer"  =>  {
  #     "name"    =>"Don Petersen",
  #     "login"    =>"",
  #     "email"    =>"don.petersen@factorylabs.com"
  #   }
  # }
  class Commit
    attr_accessor :repository
    attr_reader :author
    attr_reader :message, :sha

    def initialize(o)
      @url = o["url"]
      @message = o["message"]
      @sha = o["id"]
      @author = GithubBotz::Author.new(o["author"])
    end

    def url
      "http://github.com#{@url}"
    end
  end
end

class GithubApiHelper
  attr_reader :username, :api_key

  def initialize(username, api_key)
    @username = username
    @api_key = api_key
  end

  def commit(repository_owner, repository_name, sha)
    repository_object = make_request("/api/v2/json/repos/show/#{repository_owner}/#{repository_name}")["repository"]
    repository = GithubBotz::Repository.new(repository_object)

    commit_object = make_request("/api/v2/json/commits/show/#{repository_owner}/#{repository_name}/#{sha}")["commit"]
    commit = GithubBotz::Commit.new(commit_object)
    commit.repository = repository

    commit
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
