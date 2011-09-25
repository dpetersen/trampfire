class Trampfire.MessageFilter
  constructor: (tagList) ->
    @tagList = tagList

  shouldBeVisible: (message) ->
    @tagList.get(message.tag().id)?
