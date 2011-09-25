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
    @el.attr("data-dropdown", "dropdown")

  isActive: ->
    @el.hasClass("active")?

  deactivate: ->
    @el.removeClass("active")
    @el.removeAttr("data-dropdown")

  # TODO: Need to just do a conditional and have two templates
  render: ->
    @el = $("<li><a href='#'>#{ @label }</a></li>")
    @el.attr("id", @domId) if @domId
    @addDropdownMarkup() unless @isSystemTab()

    @delegateEvents()
    @tabBar.append(@el)

  isSystemTab: ->
    @domId == "add-tab" || @domId == "firehose"

  addDropdownMarkup: ->
    @el.addClass("dropdown")
    @$("a").addClass("dropdown-toggle")
    dropdownList = $("<ul class='dropdown-menu'></ul>").appendTo(@el)

    _.each @tab.get("tagList").models, (tag) =>
      dropdownList.append($("<li><a href='#'>#{ tag.get("name") }</a></li>"))

  clicked: (event) ->
    event.preventDefault()
    @trigger("clicked", this)
