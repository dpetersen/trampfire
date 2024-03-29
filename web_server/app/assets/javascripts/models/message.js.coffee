class Trampfire.Message extends Backbone.Model
  user: ->
    @cachedUser ?= new Trampfire.User(@get("user_hack"))

  tag: ->
    @cachedTag ?= new Trampfire.Tag(@get("tag_hack"))

  validate: (attributes) ->
    unless attributes.data? && attributes.data != ""
      return "A message must be provided!"

  isForId: (id) ->
    @get("id") == id

