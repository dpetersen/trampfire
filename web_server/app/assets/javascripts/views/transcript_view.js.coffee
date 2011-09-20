class Trampfire.TranscriptView extends Backbone.View
  el: "#transcript"

  initialize: ->
    $(@el).resize => @autoscroll()
    @messageViews = []
    @loadInitialMessages()

  loadInitialMessages: ->
    messages = $(@el).data("messages")
    transcript = new Trampfire.Transcript(messages)
    transcript.each (message) => @chatMessageReceived(message)

  # This is a bit of a hack.  Need a SystemMessage class or something.
  systemMessageReceived: (text) ->
    messageView = new Trampfire.MessageView(transcript: $(@el))
    messageView.appendToTranscript("System", text)

  chatMessageReceived: (message) ->
    messageView = new Trampfire.MessageView(message: message, transcript: $(@el))
    messageView.render()

    @messageViews.push messageView
    @autoscroll()

  updateMessageReceived: (message) ->
    @findMessageViewForId(message.get("id")).updateHTML(message.get("data"))
    @autoscroll()

  findMessageViewForId: (id) ->
    _.detect @messageViews, (messageView) ->
      messageView.isForId(id)

  autoscroll: ->
    $("body").scrollTop($(document).height())
