#= require vendor/load_orderer

class SocketConnection
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
    message = $.parseJSON(messageEvent.data)

    switch message.type
      when "system"
        @trigger "socket:message:system", message.data
      when "chat"
        @trigger "socket:message:chat", message.user.display_name, message.tag.name, message.data
      when "roster"
        roster = new Roster(message.clients)
        @trigger "socket:message:roster", roster
      else
        console.info "Got unknown message type: '#{ message.type }'"

  sendMessage: (message) ->
    @socket.send JSON.stringify(message.toJSON())

class User extends Backbone.Model

class Roster extends Backbone.Collection
  model: User

class Message extends Backbone.Model
  validate: (attributes) ->
    unless attributes.data? && attributes.data != ""
      return "A message must be provided!"

class AppView extends Backbone.View
  el: "#main"

  initialize: ->
    @roster = new Roster
    @transcriptView = new TranscriptView
    @chatView = new ChatView
    @tagsView = new TagsView
    @rosterView = new RosterView

    # We're big on security around here.  Wait a minute...
    email = $("#transcript").data("email")
    @socketConnection = new SocketConnection("ws://localhost:8080?email=#{ email }")

    @bindNetworkEvents()
    @bindUIEvents()

  bindNetworkEvents: ->
    @socketConnection.bind("socket:connected", @serverReady, this)
    @socketConnection.bind("socket:message:system", @transcriptView.systemMessageReceived, @transcriptView)
    @socketConnection.bind("socket:message:chat", @transcriptView.chatMessageReceived, @transcriptView)
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

class ChatView extends Backbone.View
  el: "#chat"

  activeTagName: ""

  events:
    "submit form": "submitPressed"

  initialize: ->
    @form = @$("form")
    @outgoing = @$("#outgoing")
    @sendButton = @$("input[type='submit']")
    @activeTagLabel = @$(".activeTag")

    @bind("chat:newMessage", @clearMessageField)

  enable: ->
    @outgoing.removeClass("disabled")
    @sendButton.removeClass("disabled")

  clearMessageField: ->
    @outgoing.val("")

  submitPressed: (event) ->
    message = new Message
    if message.set(type: 'chat', data: @outgoing.val(), tag: @activeTagName)
      @removeErrorState()
      @trigger "chat:newMessage", message
    else @setErrorState()

    event.preventDefault()

  setErrorState: ->
    @$(".control-wrapper").addClass("error")

  removeErrorState: ->
    @$(".control-wrapper").removeClass("error")

  activeTagChanged: (tag) ->
    @activeTagName = tag
    @updateActiveTagLabel()

  updateActiveTagLabel: ->
    @activeTagLabel.text(@activeTagName)

class TagsView extends Backbone.View
  el: "#tags"

  events:
    "click a": "tagLinkClicked"

  tags: ->
    @$("a")

  initialize: ->
    @activateTagLink(@tags().first())

  tagLinkClicked: (event) ->
    @activateTagLink($(event.currentTarget))
    event.preventDefault()

  activateTagLink: (tagLink) ->
    @currentTagLink.parent("li").removeClass("active") if @currentTagLink
    tagLink.parent("li").addClass("active")

    @currentTagLink = tagLink
    @notifyTagChange()

  notifyTagChange: ->
    @trigger "tags:selectedChanged", @currentTagLink.text()

class TranscriptView extends Backbone.View
  el: "#transcript"

  initialize: ->
    $(@el).resize => @autoscroll()

  systemMessageReceived: (text) ->
    @appendToTranscript("System", text)

  chatMessageReceived: (user, tag, text) ->
    @appendToTranscript("#{ user } @ #{ tag }", text)

  appendToTranscript: (author, text) ->
    $(@el).append("<dl><dt>#{ author }</dt><dd>#{ text }</dd></dl>")
    @autoscroll()

  autoscroll: ->
    $("body").scrollTop($(document).height())

class RosterView extends Backbone.View
  el: "#roster"

  initialize: ->
    @rosterList = @$("ul")

  clearRoster: ->
    @rosterList.empty()

  updateRoster: (roster) ->
    @roster = roster
    @render()

  render: ->
    @clearRoster()
    @roster.each (user) =>
      @rosterList.append("<li>#{ user.get("nick") }</li>")

jQuery ->
  window.App = new AppView
