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

  render: ->
    html = 
      if @isSystemTab() then @htmlForSystemTab()
      else @htmlForDropdownTab()

    @el = $(html)
    @tabBar.append(@el)
    @delegateEvents()

  htmlForSystemTab: ->
    JST["templates/basic_tab"](domId: @domId, label: @label)

  htmlForDropdownTab: ->
    tags = @tab.get("tagList").models
    JST["templates/dropdown_tab"](domId: @domId, label: @label, tags: tags)

  isSystemTab: ->
    @domId == "add-tab" || @domId == "firehose"

  clicked: (event) ->
    event.preventDefault()
    @trigger("clicked", this)
