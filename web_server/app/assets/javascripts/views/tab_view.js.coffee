class Trampfire.TabView extends Backbone.View
  events:
    "click a": "clicked"

  initialize: (tab, tabBarView, domId = null) ->
    @tab = tab
    @domId = domId
    @label = @tab.get("name")
    @tabBarView = tabBarView
    @tabBar = $(@tabBarView.el)

  activate: ->
    @el.addClass("active")

  deactivate: ->
    @el.removeClass("active")

  render: ->
    @el = $("<li><a href='#'>#{ @label }</a></li>")
    @el.attr("id", @domId) if @domId
    @delegateEvents()
    @tabBar.append(@el)

  clicked: (event) ->
    @trigger("clicked", this)
    event.preventDefault()
