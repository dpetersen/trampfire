require 'active_support/core_ext'
require 'warden'
require 'sprockets'
require './google_auth_strategy'
require './access_control'
require './trampfire'

use Rack::Session::Cookie,
    secret: "awf89h27389y3419yhasiljfeklaj892ynmkjlioqwd"

use Warden::Manager do |manager|
  manager.default_strategies :google
  manager.failure_app = AccessControlApp
end


use AccessControlApp
use TrampfireApp

bot_path = File.join(File.dirname(__FILE__), '../socket_server/bots/activated')
activated_bot_names = Pathname.glob("#{bot_path}/*/").map { |i| i.basename.to_s }

bot_endpoint_hash = {}

activated_bot_names.each do |bot_name|
  rack_path = File.join(bot_path, bot_name, "rack")

  if File.exist?(rack_path)
    rack_files = Pathname.glob("#{rack_path}/*.rb").map { |i| i.basename.to_s.gsub(".rb", "") }

    rack_files.each do |rack_file|
      require File.join(rack_path, rack_file)

      app_class_name = bot_name.camelize + "Bot::Rack::" + rack_file.camelize
      app_class = app_class_name.constantize

      bot_endpoint_hash["/bots/#{bot_name}/#{rack_file}"] = app_class.new
    end
  end
end

sprockets = Sprockets::Environment.new
sprockets.append_path 'app/assets/javascripts'
sprockets.append_path 'app/assets/stylesheets'

app_hash = bot_endpoint_hash.merge("/assets" => sprockets)

run Rack::URLMap.new(app_hash)
