module Config
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  def config
    self.class.config
  end

  module ClassMethods
    def config
      @config
    end

    protected

    def inherited(subclass)
      bot_directory_name = subclass.name.underscore.gsub(/_bot/, '')
      bot_config = File.join(PATHS::SOCKET_SERVER::BOTS, bot_directory_name, "config.yml")

      if File.exists?(bot_config)
        subclass.instance_variable_set(:"@config", YAML::load(File.open(bot_config)))
      end
    end
  end
end
