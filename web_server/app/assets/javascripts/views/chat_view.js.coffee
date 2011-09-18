class Trampfire.ChatView extends Backbone.View
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
    message = new Trampfire.Message
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
