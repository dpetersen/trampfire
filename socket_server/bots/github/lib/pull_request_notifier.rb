class PullRequestNotifier
  attr_reader :new_pull_requests

  def initialize(api)
    @api = api

    fetch_pull_requests_for_watched_repositories
    process_new_pull_requests
  end

protected

  def fetch_pull_requests_for_watched_repositories
    @new_pull_requests = {}

    RepositoryWatch.all.each do |repository_watch|
      fetch_pull_requests_for(repository_watch)
    end
  end

  def fetch_pull_requests_for(repository_watch)
    pull_requests = @api.pull_requests(repository_watch.owner_login, repository_watch.repository_name)
    pulls = pull_requests["pulls"]
    return unless pulls

    pulls.each do |pull_object|
      original_owner = pull_object["base"]["user"]["login"]
      repository_name = pull_object["base"]["repository"]["name"]
      number = pull_object["number"]

      previously_seen = PullRequest.where(
        owner_login: original_owner,
        repository_name: repository_name,
        pull_request_number: number
      ).exists?

      unless previously_seen
        @new_pull_requests[repository_watch.destination_tag_name] ||= []

        @new_pull_requests[repository_watch.destination_tag_name] << pull_object
        PullRequest.create(
          owner_login: original_owner,
          repository_name: repository_name,
          pull_request_number: number
        )
      end
    end
  end

  def process_new_pull_requests
    @new_pull_requests.keys.each do |tag_name|
      html = ""
      @new_pull_requests[tag_name].each do |pull_request|
        title = pull_request["title"]
        pull_requestor = pull_request["user"]["name"]
        project = "#{pull_request["base"]["user"]["name"]}/#{pull_request["base"]["repository"]["name"]}"

        html << "<strong>#{title}</strong>"
        html << " from #{pull_requestor}"
        html << " in project #{project}"
        html << "<br />"
      end

      send_new_pull_requests(tag_name, html)
    end
  end

  def send_new_pull_requests(tag_name, html)
    message_object = MessageFromFactory.new(tag_name, "GithubBot", html).message

    BotInitiatedInterprocessMessage.new(
      "github",
      "pull_requests",
      message_hash: message_object
    ).send_to_asynchronous_pipe
  end
end
