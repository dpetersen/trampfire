require 'yaml'

module DatabaseConfig
  def self.config
    config_path = File.join(File.dirname(__FILE__), 'database.yml')
    @config ||= YAML::load(File.open(config_path))["development"]
  end

  def self.adapter
    config["adapter"]
  end

  def self.database
    config["database"]
  end

  def self.host
    config["host"]
  end

  def self.username
    config["username"]
  end

  def self.password
    config["password"]
  end

  def self.connection_string
    "#{DatabaseConfig.adapter}://#{DatabaseConfig.host}/#{DatabaseConfig.database}"
  end
end
DatabaseConfig.config
