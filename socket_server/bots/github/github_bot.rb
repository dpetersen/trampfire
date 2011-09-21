require 'active_record'
require 'logger'
require './models/models'
require '../bot_base'
require '../bot_request_base'
require './lib/github_api_helper'

require 'pry'

class GithubBotRequest < BotRequestBase
  def handle_bot_message
    post_commit_object = JSON.parse(message)

    repository_owner = post_commit_object["repository"]["owner"]["name"]
    repository_name = post_commit_object["repository"]["name"]

    message_html = "<h4>Changes have been pushed to '#{repository_name}'</h4>"

    post_commit_object["commits"].each do |commit_object|
      sha = commit_object["id"]
      api =  GithubApiHelper.new(config["username"], config["api_key"])
      commit = api.commit(repository_owner, repository_name, sha)

      view_hash = build_view_hash_for_commit(repository_owner, repository_name, sha)
      message_html << render_view("commit", view_hash)
    end

    message_html
  end

  def process
    if message =~ /^http(?:s)?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/commit\/([a-f0-9]{40})$/
      repository_owner = $1
      repository_name = $2
      sha = $3

      within_subprocess do
        view_hash = build_view_hash_for_commit(repository_owner, repository_name, sha)
        html = render_view("commit", view_hash)

        message_hash["data"] = html
        @asynchronous_pipe.puts message_hash.to_json
        @asynchronous_pipe.flush
      end

      octocatize_message(message)
    end
  end

protected

  def octocatize_message(message)
    octocat_image_url = "http://th00.deviantart.net/fs70/150/i/2011/178/a/f/octocat_by_rstovall-d3k6a7n.jpg"
    %{<a href="#{message}"><img src="#{octocat_image_url}" width="50" height="50" />#{message}</a>}
  end

  def build_view_hash_for_commit(repository_owner, repository_name, sha)
    api =  GithubApiHelper.new(config["username"], config["api_key"])
    commit = api.commit(repository_owner, repository_name, sha)

    {
      commit: commit,
      repository: commit.repository
    }
  end
end

class GithubBot < BotBase
  def initialize
    ActiveRecord::Base.establish_connection(
      :adapter  => "mysql2",
      :host     => "localhost",
      :username => "root",
      :password => "",
      :database => "github_bot_development",
      :encoding => 'utf8'
    )
    ActiveRecord::Base.logger = Logger.new(STDOUT)

    super 
  end
end

GithubBot.new
