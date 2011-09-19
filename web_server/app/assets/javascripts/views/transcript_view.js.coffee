class Trampfire.Transcript extends Backbone.Collection
  model: Trampfire.Message

class Trampfire.TranscriptView extends Backbone.View
  el: "#transcript"

  initialize: ->
    $(@el).resize => @autoscroll()
    @loadInitialMessages()

  loadInitialMessages: ->
    messages = $(@el).data("messages")
    transcript = new Trampfire.Transcript(messages)
    transcript.each (message) => @chatMessageReceived(message)

  systemMessageReceived: (text) ->
    @appendToTranscript("System", text)

  updateMessageReceived: (message) ->
    @updateTranscript(message.get("id"), message.get("data"))

  chatMessageReceived: (message) ->
    author = "#{ message.user().get("display_name") } @ #{ message.tag().get("name") }"
    text = message.get("data")
    @appendToTranscript(author, text, message.get("id"))

  appendToTranscript: (author, text, id) ->
    $(@el).append(JST["templates/message"](id: id, author: author, text: text))
    @autoscroll()

  updateTranscript: (id, text) ->
    @$("dl[data-id='#{ id }'] dd").html(text)

  autoscroll: ->
    $("body").scrollTop($(document).height())
