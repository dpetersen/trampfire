require 'pathname'

class AppManager
  def initialize
    @apps = Pathname.glob("apps/*/").map { |i| i.basename.to_s }
    connect_incoming_named_pipe
  end

  def process(message)
    @apps.inject(message) do |message, app_directory|
      app_pipe = open("apps/#{app_directory}/incoming", "w+")
      app_pipe.puts message
      app_pipe.flush

      @incoming_pipe.gets
    end
  end

  def self.process(message)
    @instance ||= self.new
    @instance.process(message)
  end

protected

  def connect_incoming_named_pipe
    path = "apps/app_manager_incoming"
    `mkfifo #{path}` unless File.exist?(path)
    @incoming_pipe = open(path, "r+")
  end
end
