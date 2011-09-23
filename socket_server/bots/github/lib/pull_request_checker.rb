class PullRequestChecker
  attr_reader :new_pull_requests

  def initialize(api)
    @api = api
    @new_pull_requests = []

    RepositoryWatch.all.each do |repository_watch|
      pull_requests_for_repository(repository_watch)
    end
  end

protected

  def pull_requests_for_repository(repository_watch)
    pull_requests = @api.pull_requests(repository_watch.owner_login, repository_watch.repository_name)

    pull_requests["pulls"].each do |pull_object|
      original_owner = pull_object["base"]["user"]["login"]
      repository_name = pull_object["base"]["repository"]["name"]
      number = pull_object["number"]

      previously_seen = PullRequest.where(
        owner_login: original_owner,
        repository_name: repository_name,
        pull_request_number: number
      ).exists?

      unless previously_seen
        @new_pull_requests << pull_object
        PullRequest.create(
          owner_login: original_owner,
          repository_name: repository_name,
          pull_request_number: number
        )
      end
    end
  end
end
