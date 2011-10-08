module RepositoryWatchForPostCommitHandler
  def handle
    post_commit_object = JSON.parse(message_hash)

    repository_owner = post_commit_object["repository"]["owner"]["name"]
    repository_name = post_commit_object["repository"]["name"]

    repository_watch = RepositoryWatch.where(owner_login: repository_owner, repository_name: repository_name).first
    repository_watch.as_json.to_json
  end
end
