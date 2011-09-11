require 'pathname'

class AppManager
  def initialize
    @apps = Pathname.glob("apps/*/").map { |i| i.basename.to_s }
  end

  def process(message)
    @apps.inject(message) do |message, app_directory|
      app_incoming_pipe = open("apps/#{app_directory}/incoming", "w+")
      app_incoming_pipe.puts message
      app_incoming_pipe.flush

      app_outgoing_pipe = open("apps/outgoing", "r+")
      app_outgoing_pipe.gets
    end
  end

  def self.process(message)
    @instance ||= self.new
    @instance.process(message)
  end
end
