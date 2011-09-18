class Trampfire.SocketConnection
  constructor: (@url) ->
    _.extend(this, Backbone.Events)

    @checkSocketSupport()

    try
      @socket = new WebSocket(@url)
      @socket.onopen = @onOpen
      @socket.onmessage = @onMessage
      @socket.onclose = @onClose
    catch exception
      alert "Error: #{ exception }"

  checkSocketSupport: ->
    supportsSockets = `"WebSocket" in window`
    alert "You have no support for WebSockets in this browser.  Bye." unless supportsSockets

  onOpen: =>
    @trigger "socket:connected"

  onClose: ->
    alert "Socket connection has closed unexpectedly!"

  onMessage: (messageEvent) =>
    console.info "onMessage"
    console.info messageEvent.data
    message = $.parseJSON(messageEvent.data)

    switch message.type
      when "system"
        @trigger "socket:message:system", message.data
      when "chat"
        @trigger "socket:message:chat", new Trampfire.Message(message)
      when "roster"
        roster = new Trampfire.Roster(message.clients)
        @trigger "socket:message:roster", roster
      else
        console.info "Got unknown message type: '#{ message.type }'"

  sendMessage: (message) ->
    @socket.send JSON.stringify(message.toJSON())
