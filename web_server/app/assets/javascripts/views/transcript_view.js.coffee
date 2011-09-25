class Trampfire.TranscriptView extends Backbone.View
  el: "#transcript"
  nonSystemMessageViews: []

  initialize: ->
    $(@el).resize => @autoscroll()
    @loadInitialMessages()

  loadInitialMessages: ->
    messages = $(@el).data("messages")
    @transcript = new Trampfire.Transcript(messages)
    @transcript.each (message) => @messageAdded(message)
    @transcript.bind("add", @messageAdded, this)

  # This is a bit of a hack.  Need a SystemMessage class or something.
  systemMessageReceived: (text) ->
    messageView = new Trampfire.MessageView(transcriptView: this)
    messageView.appendToTranscript("System", text)

  chatMessageReceived: (message) ->
    @transcript.add(message)

  messageAdded: (message) ->
    messageView = new Trampfire.MessageView(message: message, transcriptView: this)
    @nonSystemMessageViews.push(messageView)
    messageView.render()

    if @currentMessageFilter && @currentMessageFilter.shouldBeVisible(messageView.message)
      messageView.show()

    @autoscroll()

  updateMessageReceived: (updatedMessage) ->
    messageForUpdate = @transcript.messageForId(updatedMessage.get("id"))
    messageForUpdate.set(data: updatedMessage.get("data"))

  autoscroll: ->
    $("body").scrollTop($(document).height())

  setMessageFilter: (messageFilter) ->
    @currentMessageFilter = messageFilter
    _.each @nonSystemMessageViews, (messageView) =>
      if @currentMessageFilter.shouldBeVisible(messageView.message)
        messageView.show()
      else
        messageView.hide()
