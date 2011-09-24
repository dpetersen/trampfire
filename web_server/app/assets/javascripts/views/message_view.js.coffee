class Trampfire.MessageView extends Backbone.View
  initialize: ->
    @message = @options.message
    @message.bind("change:data", @messageUpdated, this)
    @transcriptView = @options.transcriptView
    @transcript = $(@transcriptView.el)

  render: ->
    author = "#{ @message.get("author") } @ #{ @message.tag().get("name") }"
    text = @message.get("data")

    @appendToTranscript(author, text, @message.get("id"))

  appendToTranscript: (author, text, id) ->
    messageHTML = JST["templates/message"](id: id, author: author, text: text)
    @transcript.append(messageHTML)
    @el = @transcript.find("dl[data-id='#{id}']")

  messageUpdated: (message) ->
    @updateHTML(message.get("data"))

  updateHTML: (html) ->
    @$("dd").html(html)
    @transcriptView.autoscroll()
