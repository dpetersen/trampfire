jQuery ->

  socketSupport = `"WebSocket" in window`
  unless socketSupport
    alert "You have no support for WebSockets in this browser.  Bye."
  else

    try
      # We're big on security around here.  Wait a minute...
      email = $("#transcript").data("email")
      host = "ws://localhost:8080?email=#{email}"
      socket = new WebSocket(host)

      console.log "Socket Status: #{ socket.readyState }"

      socket.onopen = ->
        console.log "onopen #{ socket.readyState }"
        $("#transcript").append("<p>Connected...</p>")

        $("form").submit ->
          outgoing = $("#outgoing")
          socket.send outgoing.val()
          outgoing.val ""
          return false

      socket.onmessage = (message) ->
        console.log "onmessage #{ message.data }"
        $("#transcript").append("<p>#{ message.data }</p>")

      socket.onclose = ->
        console.log "onclose #{ socket.readyState }"

    catch exception
      alert "Error: #{ exception }"
