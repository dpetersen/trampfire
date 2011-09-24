require 'active_record'
require 'logger'

require_relative '../../../lib/shared'
require File.join(PATHS::SOCKET_SERVER::BOT_LIB, 'bot_essentials')

require_relative 'models/models'
require_relative 'lib/libs'

class GithubBotRequest < BotRequestBase
  handle_bot_event("post_commit", PostCommitEventHandler)

  handle_bot_event("create_repository_watch") do
    repository_watch_attributes = JSON.parse(message_hash)
    repository_watch = RepositoryWatch.create(repository_watch_attributes)
    repository_watch.as_json(methods: :errors).to_json
  end

  handle_bot_event("fetch_repository_watches") do
    RepositoryWatch.all.as_json.to_json
  end

  # TODO rename this to something more apt, like process_user_initiated_message
  def process
    if message =~ /^http(?:s)?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/commit\/([a-f0-9]{40})$/
      repository_owner = $1
      repository_name = $2
      sha = $3

      within_subprocess do
        view_hash = build_view_hash_for_commit(repository_owner, repository_name, sha)
        html = render_view("commit", view_hash)

        message_hash["data"] = html
        interprocess_message = UserInitiatedInterprocessMessage.new(message_hash: message_hash)
        asynchronous_pipe.write interprocess_message.to_json
      end

      octocatize_message(message)
    end
  end

protected

  def octocatize_message(message)
    %{<a href="#{message}"><img src="#{public_asset_path("/images/octocat.png")}" width="50" height="50" />#{message}</a>}
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

  periodically(60) do
    # TODO don't forget to nuke this before commit...
    sleep 5
    PullRequest.destroy_all

    api = GithubApiHelper.new(config["username"], config["api_key"])
    pull_requests = PullRequestChecker.new(api).new_pull_requests

    pull_requests.keys.each do |tag_name|
      html = ""
      pull_requests[tag_name].each do |pull_request|
        title = pull_request["title"]
        pull_requestor = pull_request["user"]["name"]
        project = "#{pull_request["base"]["user"]["name"]}/#{pull_request["base"]["repository"]["name"]}"

        html << "<strong>#{title}</strong>"
        html << " from #{pull_requestor}"
        html << " in project #{project}"
        html << "<br />"
      end

      message_object = MessageFromFactory.new(tag_name, "GithubBot", html).message

      interprocess_message = BotInitiatedInterprocessMessage.new(
        "GitHubBot",
        "pull_requests",
        message_hash: message_object
      )
      asynchronous_pipe.write interprocess_message.to_json
    end
  end
end

GithubBot.new
