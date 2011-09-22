class Trampfire.ChatView extends Backbone.View
  el: "#chat"
  enabled: false

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
    @enabled = true
    @outgoing.removeClass("disabled")
    @sendButton.removeClass("disabled")

  clearMessageField: ->
    @outgoing.val("")

  submitPressed: (event) ->
    if @enabled
      message = new Trampfire.Message
      if message.set(type: 'user_initiated', data: @outgoing.val(), tag: @activeTagName)
        @removeErrorState()
        @trigger "chat:newMessage", message
      else @setErrorState()
    else alert "I'm not ready yet.  Settle down."

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
