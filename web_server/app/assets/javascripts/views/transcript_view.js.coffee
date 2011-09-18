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

  chatMessageReceived: (message) ->
    author = "#{ message.user().get("display_name") } @ #{ message.tag().get("name") }"
    text = message.get("data")
    @appendToTranscript(author, text)

  appendToTranscript: (author, text) ->
    $(@el).append(JST["templates/message"](author: author, text: text))
    @autoscroll()

  autoscroll: ->
    $("body").scrollTop($(document).height())
