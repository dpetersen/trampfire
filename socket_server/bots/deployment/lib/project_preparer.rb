module ProjectPreparer
  def self.prepare(project)
    html = "Preparing to onboard new project '#{project.heroku_app_name}'"

    message_object = MessageFromFactory.new(
      project.destination_tag_name,
      "DeploymentBot",
      html
    ).message

    BotInitiatedInterprocessMessage.new(
      "deployment_bot",
      "project_prepare",
      message_hash: message_object
    ).send_to_asynchronous_pipe

    output = `cd #{DeploymentBot::REPO_STORAGE_PATH} && git clone #{project.clone_url} #{project.id} --progress 2>&1`
    output += `cd #{project.path} && git remote add heroku git@heroku.com:#{project.heroku_app_name}.git`

    html = "Project '#{project.heroku_app_name}' imported:"
    html << "<pre>#{output}</pre>"
    message_object["data"] = html

    UserInitiatedInterprocessMessage.new(message_hash: message_object).send_to_asynchronous_pipe
  end
end
