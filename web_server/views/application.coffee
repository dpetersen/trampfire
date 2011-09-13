jQuery ->

  socketSupport = `"WebSocket" in window`
  unless socketSupport
    alert "You have no support for WebSockets in this browser.  Bye."
  else

    currentTag = $("#tags a").first().text()
    $("#tags a").click ->
      currentTag = $(this).text()

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
          message = { type: 'chat', data: outgoing.val(), tag: currentTag }
          socket.send JSON.stringify(message)
          outgoing.val("")
          return false

      socket.onmessage = (message) ->
        console.log "onmessage #{ message.data }"
        json = $.parseJSON(message.data)

        if json.type == "system" || json.type == "chat"
          author = if json.type == "system" then "System" else "#{ json.user.display_name } @ #{ json.tag.name }"
          $("#transcript").append("<p><dl><dt>#{ author }</dt><dd>#{ json.data }</dd></dl></p>")
        else if json.type == "roster"
          console.log "Roster update"
          roster = $("#roster")
          roster.empty()
          for user in json.clients
            roster.append("<li>#{ user.nick }</li>")
        else
          console.log("I don't know what to do with message type: #{ json.type }")

      socket.onclose = ->
        console.log "onclose #{ socket.readyState }"

    catch exception
      alert "Error: #{ exception }"
