require 'sinatra'
require 'omniauth'
require 'openid/store/filesystem'

class TrampfireApp < Sinatra::Base
  use Rack::Session::Cookie

  use OmniAuth::Strategies::OpenID,
      OpenID::Store::Filesystem.new('/tmp'),
      name: 'google',
      identifier: 'https://www.google.com/accounts/o8/id'

  post '/auth/google/callback' do
    authentication_hash = request.env['omniauth.auth']
    # {
    #   "provider"=>"google",
    #   "uid"=>"https://www.google.com/accounts/o8/id?id=AItOawmJwY7EjluMJiBYQeYcAjGICqqOm1nfY6o",
    #   "user_info"=>{
    #     "email"=>"don.petersen@factorylabs.com",
    #     "first_name"=>"Don",
    #     "last_name"=>"Petersen",
    #     "name"=>"Don Petersen"
    #   }
    # }
  end

  get '/' do
    haml :index
  end

  get '/application.js' do
    coffee :application
  end
end
