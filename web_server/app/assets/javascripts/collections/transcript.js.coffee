class Trampfire.Transcript extends Backbone.Collection
  model: Trampfire.Message

  messageForId: (id) ->
    @detect (message) -> message.isForId(id)
