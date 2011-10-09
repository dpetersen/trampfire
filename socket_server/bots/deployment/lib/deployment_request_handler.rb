module DeploymentRequestHandler
  def process_for_deployment_request
    if message =~ /^DeploymentBot: Can you please deploy (\S*)\?$/
      requested_name = $1

      within_subprocess do
        process_deployment_request(requested_name)
      end

      return nil
    end
  end

protected

  def process_deployment_request(requested_name)
    if project = Project.where(heroku_app_name: requested_name).first
      response_for_found_project(project)
    else
      response_for_unknown_project(requested_name)
    end
  end

  def response_for_found_project(project)
    send_deployment_starting_message(project)

    output = `cd #{project.path} && git pull origin master && git push heroku master 2>&1`

    send_deployment_finished_message(project, output)
  end

  def send_deployment_starting_message(project)
    message_object = MessageFromFactory.new(
      "Trampfire",
      "DeploymentBot",
      render_view("preparing", name: project.heroku_app_name)
    ).message

    BotInitiatedInterprocessMessage.new(
      "deployment_bot",
      "unsuccessful_deploy_request",
      message_hash: message_object
    ).send_to_asynchronous_pipe
  end

  def send_deployment_finished_message(project, output)
    message_object = MessageFromFactory.new(
      "Trampfire",
      "DeploymentBot",
      render_view("finished", output: output, name: project.heroku_app_name)
    ).message

    BotInitiatedInterprocessMessage.new(
      "deployment_bot",
      "successful_deploy_request",
      message_hash: message_object
    ).send_to_asynchronous_pipe
  end

  def response_for_unknown_project(requested_name)
    message_object = MessageFromFactory.new(
      "Trampfire",
      "DeploymentBot",
      render_view("unknown", requested_name: requested_name)
    ).message

    BotInitiatedInterprocessMessage.new(
      "deployment_bot",
      "unsuccessful_deploy_request",
      message_hash: message_object
    ).send_to_asynchronous_pipe
  end
end
