require 'warden'
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
run TrampfireApp
