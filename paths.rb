module PATHS
  module SHARED
    BASE = File.join(File.dirname(__FILE__))
    MODELS = File.join(BASE, 'models')
  end

  module WEB_SERVER
    BASE = File.join(SHARED::BASE, 'web_server')
    LIB = File.join(BASE, 'lib')
  end

  module SOCKET_SERVER
    BASE = File.join(SHARED::BASE, 'socket_server')
    LIB = File.join(BASE, 'lib')
    BOT_LIB = File.join(LIB, 'bot')
    BOTS = File.join(BASE, 'bots')
    ACTIVATED_BOTS = File.join(BOTS, 'activated')
  end
end

