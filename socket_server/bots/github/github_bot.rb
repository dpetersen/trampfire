require '../bot_base'
require '../bot_request_base'
require './github_api_helper'
require 'digest/md5'

require 'pry'

class GithubBotRequest < BotRequestBase
  def process
    if message =~ /^http(?:s)?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/commit\/([a-f0-9]{40})$/
      user = $1
      repo = $2
      sha = $3

      within_subprocess do
        view_hash = build_view_hash_for_commit(user, repo, sha)
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
    %{<a href="#{message}"><img src="#{octocat_image_url}" />#{message}</a>}
  end

  def build_view_hash_for_commit(user_name, repo_name, sha)
    github =  GithubApiHelper.new(config["username"], config["api_key"])
    repo = github.repo(user_name, repo_name)
    commit = github.commit(user_name, repo_name, sha)
    md5 = Digest::MD5.hexdigest(commit["author"]["email"])
    gravatar_url = "http://gravatar.com/avatar/#{md5}"

    {
      repo_name: repo["name"],
      repo_path: repo["url"],
      commit_author: commit["author"]["name"],
      gravatar_url: gravatar_url,
      commit_url: "http://github.com#{commit["url"]}",
      commit_message: commit["message"],
      sha: sha,
      user_path: "http://github.com/#{commit["author"]["login"]}",
      repo_owner: user_name,
      repo_owner_path: "http://github.com/#{user_name}"
    }
  end
end

class GithubBot < BotBase
end

GithubBot.new
