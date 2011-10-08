require 'nokogiri'

module ActivityHookHandler
  def handle
    activity_xml = Nokogiri::XML(message_hash)

    project_id = activity_xml.at_css("activity project_id").text
    description = activity_xml.at_css("activity description").text

    if project = Project.where(project_id: project_id).first
      message_html = "<em>#{description}</em>"

      message_object = MessageFromFactory.new(
        project.destination_tag_name,
        "PivotalTrackerBot",
        message_html
      ).message

      BotInitiatedInterprocessMessage.new(
        "pivotal_tracker",
        "activity_hook",
        message_hash: message_object
      ).send_to_asynchronous_pipe
    else raise "Got activity for a project I don't know about: #{project_id}"
    end
  end
end
