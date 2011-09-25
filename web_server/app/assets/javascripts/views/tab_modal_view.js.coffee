class Trampfire.TabModalView extends Backbone.View
  events:
    "click a.save": "savePressed"

  initialize: (tabBarView) ->
    @tabBarView = tabBarView
    @tabBar = $(@tabBarView.el)

  render: ->
    template = JST["templates/modal"](
      heading: "My Modal",
      body: JST["templates/new_tab_form"](tags: @tabBarView.tagList.models)
    )
    @el = $(template)
    @el.insertAfter(@tabBar)
    @el.bind("hide", => @hidden())
    @popUp()

  nameValue: ->
    @$("input[name='name']").val()

  tagListFromSelected: ->
    tagList = new Trampfire.TagList()
    _.each @$("select option:selected"), (option) ->
      o = $(option)
      tag = new Trampfire.Tag(id: o.val(), name: o.text())
      tagList.add(tag)
    tagList

  popUp: ->
    @el.modal(show: true, backdrop: true, keyboard: true)
    @delegateEvents()

  hidden: ->
    @el.unbind()
    @el.remove()

  hide: ->
    @el.modal("hide")

  savePressed: (event) ->
    event.preventDefault()
    @hide()
    tag = new Trampfire.Tab(name: @nameValue(), tagList: @tagListFromSelected())
    @trigger("saved", tag)
