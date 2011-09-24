module CommitChatMessageHandler
  def process_for_github_commit_links
    if message =~ /^http(?:s)?:\/\/(?:www\.)?github\.com\/([^\/]+)\/([^\/]+)\/commit\/([a-f0-9]{40})$/
      repository_owner = $1
      repository_name = $2
      sha = $3

      within_subprocess do
        view_hash = build_view_hash_for_commit(repository_owner, repository_name, sha)
        html = render_view("commit", view_hash)

        message_hash["data"] = html
        UserInitiatedInterprocessMessage.new(message_hash: message_hash).send_to_asynchronous_pipe
      end

      octocatize_message(message)
    end
  end

protected

  def octocatize_message(message)
    %{<a href="#{message}"><img src="#{public_asset_path("/images/octocat.png")}" width="50" height="50" />#{message}</a>}
  end
end
