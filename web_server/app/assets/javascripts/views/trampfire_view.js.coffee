class Trampfire.TrampfireView extends Backbone.View
  el: "#main"

  initialize: ->
    @roster = new Trampfire.Roster
    @transcriptView = new Trampfire.TranscriptView
    @chatView = new Trampfire.ChatView
    @tagsView = new Trampfire.TagsView
    @rosterView = new Trampfire.RosterView

    # We're big on security around here.  Wait a minute...
    email = $("body").data("email")
    @socketConnection = new Trampfire.SocketConnection("ws://localhost:8080?email=#{ email }")

    @bindNetworkEvents()
    @bindUIEvents()

  bindNetworkEvents: ->
    @socketConnection.bind("socket:connected", @serverReady, this)
    @socketConnection.bind("socket:message:system", @transcriptView.systemMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:chat", @transcriptView.chatMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:update", @transcriptView.updateMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:roster", @updateRoster, this)

  bindUIEvents: ->
    @tagsView.bind("tags:selectedChanged", @chatView.activeTagChanged, @chatView)
    @chatView.bind("chat:newMessage", @socketConnection.sendMessage, @socketConnection)
    @roster.bind("reset", @rosterView.updateRoster, @rosterView)

    @tagsView.notifyTagChange() # Event is fired before anybody is listening

  serverReady: ->
    @chatView.enable()

  updateRoster: (roster) ->
    @roster.reset(roster.models)
