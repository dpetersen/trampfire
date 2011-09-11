require './apps/imager'

class AppManager
  def self.process(message)
    @apps ||= [ Imager ]

    @apps.inject(message) do |message, app|
      app.process(message)
    end
  end
end
