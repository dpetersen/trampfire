require File.join(PATHS::SHARED::BASE, 'database_config')

# This MUST go before sinatra/activerecord is required.  How the fuck
# that thing actually works as documented... well, it doesn't.
ENV["DATABASE_URL"] = DatabaseConfig.connection_string

require 'sinatra'
require 'sinatra/activerecord'
require File.join(PATHS::WEB_SERVER::LIB, 'authorization_helpers')
require File.join(PATHS::SHARED::MODELS, 'models')

class TrampfireApp < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/app/views'

  include AuthorizationHelpers

  get '/' do
    when_authenticated do
      @messages = Message.order("updated_at DESC").limit(5).all.reverse
      @tags = Tag.order("name").all
      haml :index, layout: :application
    end
  end

  post '/tabs' do
    attributes = JSON.parse(request.body.read)
    tab = Tab.create_from_json_for_user(env['warden'].user, attributes)
    if tab.persisted? then tab.as_json.to_json
    else 422
    end
  end

  put '/tabs/:id/' do
    raise "UPDATE GOT PARAMS: #{params.inspect}"
  end

  post '/tags' do
    when_authenticated do
      Tag.create(params[:tag])
      redirect '/'
    end
  end
end
