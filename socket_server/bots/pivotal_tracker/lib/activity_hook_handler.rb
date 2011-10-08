require 'nokogiri'

module ActivityHookHandler
  def handle
    activity_xml = Nokogiri::XML(message_hash)

    project_id = activity_xml.at_css("activity project_id").text

    if project = Project.where(project_id: project_id).first
      html = render_view(
        "activity_hook",
        {
          description: activity_xml.at_css("activity description").text,
          tracker_logo_path: public_asset_path("/images/tracker_logo.png")
        }
      )

      message_object = MessageFromFactory.new(
        project.destination_tag_name,
        "PivotalTrackerBot",
        html
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
