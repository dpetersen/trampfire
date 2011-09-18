class Trampfire.RosterView extends Backbone.View
  el: "#roster"

  initialize: ->
    @rosterList = @$("ul")

  clearRoster: ->
    @rosterList.empty()

  updateRoster: (roster) ->
    @roster = roster
    @render()

  render: ->
    @clearRoster()
    @roster.each (user) =>
      @rosterList.append("<li>#{ user.get("nick") }</li>")

