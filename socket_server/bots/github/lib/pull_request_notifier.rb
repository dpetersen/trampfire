class PullRequestNotifier
  include ViewHelpers

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
        html = render_view("pull_request", pull_request_view_hash(pull_request))
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

  def pull_request_view_hash(pull_request)
    repository_owner_name = pull_request["base"]["user"]["login"]
    repository_name = pull_request["base"]["repository"]["name"]
    pull_requestor = pull_request["user"]["login"]

    {
      title: pull_request["title"],
      body: pull_request["body"],
      url: pull_request["html_url"],
      pull_requestor: pull_requestor,
      pull_requestor_gravatar_url: "http://gravatar.com/avatar/#{pull_request["user"]["gravatar_id"]}",
      pull_requestor_url: "http://github.com/#{pull_requestor}",
      repository_display_name: "#{repository_owner_name}/#{repository_name}",
      repository_url: pull_request["base"]["repository"]["url"],
    }
  end
end
