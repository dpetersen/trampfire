class Trampfire.TrampfireView extends Backbone.View
  el: "#main"

  initialize: ->
    @roster = new Trampfire.Roster
    @transcriptView = new Trampfire.TranscriptView
    @chatView = new Trampfire.ChatView
    @rosterView = new Trampfire.RosterView
    @tabBarView = new Trampfire.TabBarView

    # We're big on security around here.  Wait a minute...
    email = $("body").data("email")
    @socketConnection = new Trampfire.SocketConnection("ws://localhost:31981?email=#{ email }")

    @bindNetworkEvents()
    @bindUIEvents()

    @tabBarView.setInitialTab()

  bindNetworkEvents: ->
    @socketConnection.bind("socket:connected", @serverReady, this)
    @socketConnection.bind("socket:message:system", @transcriptView.systemMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:chat", @transcriptView.chatMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:update", @transcriptView.updateMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:roster", @updateRoster, this)

  bindUIEvents: ->
    @chatView.bind("chat:newMessage", @socketConnection.sendMessage, @socketConnection)
    @roster.bind("reset", @rosterView.updateRoster, @rosterView)
    @tabBarView.bind("tab:changed", @tabChanged, this)
    @tabBarView.bind("tag:changed", @chatView.activeTagChanged, @chatView)

  serverReady: ->
    @chatView.enable()

  updateRoster: (roster) ->
    @roster.reset(roster.models)

  tabChanged: (tab) ->
    messageFilter = new Trampfire.MessageFilter(tab.get("tagList"))
    @transcriptView.setMessageFilter(messageFilter)
