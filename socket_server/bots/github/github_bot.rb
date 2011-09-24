require_relative '../../../lib/shared'
require File.join(PATHS::SOCKET_SERVER::BOT_LIB, 'bot_essentials')

require_relative 'models/models'
require_relative 'lib/libs'

class GithubBotRequest < BotRequestBase
  include CommitChatMessageHandler

  handle_bot_event("post_commit", PostCommitEventHandler)

  handle_bot_event("create_repository_watch") do
    repository_watch_attributes = JSON.parse(message_hash)
    repository_watch = RepositoryWatch.create(repository_watch_attributes)
    repository_watch.as_json(methods: :errors).to_json
  end

  handle_bot_event("fetch_repository_watches") do
    RepositoryWatch.all.as_json.to_json
  end

  def process_user_initiated_message
    process_for_github_commit_links
  end

protected

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
    autoconnect_database
    super
  end

  periodically(60) do
    # TODO don't forget to nuke this before commit...
    sleep 5
    PullRequest.destroy_all

    api = GithubApiHelper.new(config["username"], config["api_key"])
    PullRequestNotifier.new(api)
  end
end

GithubBot.new
