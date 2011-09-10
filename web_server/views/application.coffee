jQuery ->

  socketSupport = `"WebSocket" in window`
  unless socketSupport
    alert "You have no support for WebSockets in this browser.  Bye."
  else

    try
      host = "ws://localhost:8080"
      socket = new WebSocket(host)

      console.log "Socket Status: #{ socket.readyState }"

      socket.onopen = ->
        console.log "onopen #{ socket.readyState }"
        $("#transcript").append("<p>Connected...</p>")

        $("form").submit ->
          socket.send $("#outgoing").val()
          return false

      socket.onmessage = (message) ->
        console.log "onmessage #{ message.data }"
        $("#transcript").append("<p>#{ message.data }</p>")

      socket.onclose = ->
        console.log "onclose #{ socket.readyState }"

    catch exception
      alert "Error: #{ exception }"

