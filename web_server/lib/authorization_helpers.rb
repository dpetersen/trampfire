module AuthorizationHelpers
  def when_authenticated(&block)
    if env['warden'].authenticated?
      yield
    else
      haml :login, layout: :application
    end
  end
end
