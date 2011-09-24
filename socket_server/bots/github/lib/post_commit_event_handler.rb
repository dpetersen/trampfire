module PostCommitEventHandler
  def handle
    within_subprocess do
      post_commit_object = JSON.parse(message)

      repository_owner = post_commit_object["repository"]["owner"]["name"]
      repository_name = post_commit_object["repository"]["name"]

      if RepositoryWatch.where(owner_login: repository_owner, repository_name: repository_name).exists?
        message_html = "<h4>Changes have been pushed to '#{repository_name}'</h4>"

        post_commit_object["commits"].each do |commit_object|
          sha = commit_object["id"]
          api =  GithubApiHelper.new(config["username"], config["api_key"])
          commit = api.commit(repository_owner, repository_name, sha)

          view_hash = build_view_hash_for_commit(repository_owner, repository_name, sha)
          message_html << render_view("commit", view_hash)
        end

        message_hash["data"] = message_html
        interprocess_message = BotInitiatedInterprocessMessage.new("GitHubBot", "post_commit", message_hash: message_hash)
        asynchronous_pipe.write interprocess_message.to_json
      else raise "Got a post-commit hook from unknown repo: '#{repository_owner}/#{repository_name}'"
      end
    end
  end
end
