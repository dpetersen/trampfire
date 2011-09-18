class Trampfire.TagsView extends Backbone.View
  el: "#tags"

  events:
    "click a": "tagLinkClicked"

  tags: ->
    @$("a")

  initialize: ->
    @activateTagLink(@tags().first())

  tagLinkClicked: (event) ->
    @activateTagLink($(event.currentTarget))
    event.preventDefault()

  activateTagLink: (tagLink) ->
    @currentTagLink.parent("li").removeClass("active") if @currentTagLink
    tagLink.parent("li").addClass("active")

    @currentTagLink = tagLink
    @notifyTagChange()

  notifyTagChange: ->
    @trigger "tags:selectedChanged", @currentTagLink.text()

