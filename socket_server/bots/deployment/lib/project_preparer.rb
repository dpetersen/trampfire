module ProjectPreparer
  def prepare(project)
    message_object = MessageFromFactory.new(
      project.destination_tag_name,
      "DeploymentBot",
      render_view("onboarding", name: project.heroku_app_name)
    ).message

    BotInitiatedInterprocessMessage.new(
      "deployment_bot",
      "project_prepare",
      message_hash: message_object
    ).send_to_asynchronous_pipe

    output = `cd #{DeploymentBot::REPO_STORAGE_PATH} && git clone #{project.clone_url} #{project.id} --progress 2>&1`
    output += `cd #{project.path} && git remote add heroku git@heroku.com:#{project.heroku_app_name}.git`

    message_object["data"] = render_view("onboarded", name: project.heroku_app_name, output: output)
    UserInitiatedInterprocessMessage.new(message_hash: message_object).send_to_asynchronous_pipe
  end
end
