class Trampfire.TabBarView extends Backbone.View
  el: "#tab-bar"
  tagList: new Trampfire.TagList()
  tabViews: []
  activeTabView: null
  
  initialize: ->
    @$el = $(@el)

    @loadInitialTagList()
    @processExistingTabs()
    @createFirehoseTab()
    @createAddTab()

  setInitialTab: ->
    @tabClicked(@firehose)

  loadInitialTagList: ->
    @tagList = @tagList.reset(@$el.data("tags"))

  processExistingTabs: ->
    _.each @$("li"), (li) =>
      json = $(li).data("tab")
      tab = new Trampfire.Tab
        name: json.name
        tagList: new Trampfire.TagList(json.tags)
      $(li).remove() # Wait, what?  Probably want to rethink that.
      @addNewTab(tab)

  createFirehoseTab: ->
    tab = new Trampfire.Tab(name: "Fire hose", tagList: @tagList)
    @firehose = new Trampfire.TabView(tab, this, "firehose")
    @firehose.bind("clicked", @tabClicked, this)
    @firehose.render()

  createAddTab: ->
    tab = new Trampfire.Tab(name: "+")
    @addTab = new Trampfire.TabView(tab, this, "add-tab")
    @addTab.bind("clicked", @addTabClicked, this)
    @addTab.render()

  addTabClicked: ->
    @createNewTabModalView()

  addNewTab: (tab) ->
    tabView = new Trampfire.TabView(tab, this)
    tabView.bind("clicked", @tabClicked, this)
    tabView.bind("tag:clicked", @tagClicked, this)
    @tabViews.push(tabView)
    tabView.render()

  activateTab: (tabView) ->
    @activeTabView.deactivate() if @activeTabView
    @activeTabView = tabView
    @activeTabView.activate()

  tabClicked: (tabView) ->
    @activateTab(tabView)
    @trigger("tab:changed", tabView.tab)

  tagClicked: (tabId) ->
    tag = @tagList.get(tabId)
    @trigger("tag:changed", tag)

  createNewTabModalView: ->
    tabModalView = new Trampfire.TabModalView(this)
    tabModalView.bind("saved", @modalSaved, this)
    tabModalView.render()

  modalSaved: (tab) ->
    tab.save(null, success: @modalSuccess, error: @modalError)

  modalSuccess: (tab, response) =>
    @addNewTab(tab)

  modalError: (tab, response) ->
    alert "There was a problem with your Tab.  Get it together."
