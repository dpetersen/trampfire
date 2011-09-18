class Trampfire.TranscriptView extends Backbone.View
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

