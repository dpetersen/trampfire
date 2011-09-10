require 'sinatra'
require 'omniauth'
require 'openid/store/filesystem'

class AccessControlApp < Sinatra::Base
  use OmniAuth::Strategies::OpenID,
      OpenID::Store::Filesystem.new('/tmp'),
      name: 'google',
      identifier: 'https://www.google.com/accounts/o8/id'

  post '/auth/google/callback' do
    authentication_hash = request.env['omniauth.auth']
    env['rack.auth'] = authentication_hash
    env['warden'].authenticate!(:google)
    redirect '/'
  end

  get '/logout' do
    env['warden'].logout
    redirect '/'
  end

  post '/unauthenticated' do
    'Could not authenticate you.  Either you are not signed in to google apps, or not with a Factory account.'
  end
end
