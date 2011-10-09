require_relative '../../../lib/shared'
require File.join(PATHS::SOCKET_SERVER::BOT_LIB, 'bot_essentials')

require_relative 'models/models'
require_relative 'lib/libs'

class DeploymentBotRequest < BotRequestBase
  include DeploymentRequestHandler
  include ProjectPreparer

  handle_bot_event("fetch_projects") do
    Project.all.as_json.to_json
  end

  handle_bot_event("create_project") do
    Project.destroy_all

    project_attributes = JSON.parse(message_hash)
    project = Project.create(project_attributes)

    if project.persisted?
      within_subprocess do
        prepare(project)
      end
    end

    project.as_json(methods: :errors).to_json
  end

  def process_user_initiated_message
    process_for_deployment_request
  end
end

class DeploymentBot < BotBase
  REPO_STORAGE_PATH = File.join(File.dirname(__FILE__), "repositories")

  def initialize
    autoconnect_database
    super
  end
end

DeploymentBot.new
