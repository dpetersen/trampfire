class Trampfire.MessageView extends Backbone.View
  initialize: ->
    @message = @options.message
    @transcript = @options.transcript

  render: ->
    author = "#{ @message.get("author") } @ #{ @message.tag().get("name") }"
    text = @message.get("data")

    @appendToTranscript(author, text, @message.get("id"))

  appendToTranscript: (author, text, id) ->
    messageHTML = JST["templates/message"](id: id, author: author, text: text)
    @transcript.append(messageHTML)
    @el = @transcript.find("dl[data-id='#{id}']")

  isForId: (id) ->
    @message.get("id") == id

  updateHTML: (html) ->
    @$("dd").html(html)
