require 'pathname'

class AppManager
  AppsPath = "apps"

  def initialize
    @apps = Pathname.glob("#{AppsPath}/*/").map { |i| i.basename.to_s }
    connect_incoming_named_pipe
  end

  def process(message)
    message_json = jsonize_message(message)
    complete_message_json = pass_message_json_through_app_bus(message_json)
    JSON.parse(complete_message_json)["data"]
  end

  def self.process(message)
    @instance ||= self.new
    @instance.process(message)
  end

protected

  def connect_incoming_named_pipe
    path = "#{AppsPath}/app_manager_incoming"
    `mkfifo #{path}` unless File.exist?(path)
    @incoming_pipe = open(path, "r+")
  end

  def jsonize_message(message)
    {
      type: "chat",
      data: message
    }.to_json
  end

  def pass_message_json_through_app_bus(message_json)
    @apps.inject(message_json) do |passed_message, app_directory|
      app_pipe = open("#{AppsPath}/#{app_directory}/incoming", "w+")
      app_pipe.puts passed_message
      app_pipe.flush

      @incoming_pipe.gets
    end
  end
end
