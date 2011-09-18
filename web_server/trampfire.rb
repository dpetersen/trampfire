require 'pry'

require '../database_config'

# This MUST go before sinatra/activerecord is required.  How the fuck
# that thing actually works as documented... well, it doesn't.
ENV["DATABASE_URL"] = DatabaseConfig.connection_string

require 'sinatra'
require 'sinatra/activerecord'
require './lib/authorization_helpers'
require '../models/models'

class TrampfireApp < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/app/views'

  include AuthorizationHelpers

  get '/' do
    when_authenticated do
      @messages = Message.order("updated_at DESC").limit(5).all.reverse
      haml :index, layout: :application
    end
  end

  post '/tags' do
    when_authenticated do
      Tag.create(params[:tag])
      redirect '/'
    end
  end
end
