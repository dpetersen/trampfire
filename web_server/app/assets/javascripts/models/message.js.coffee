class Trampfire.Message extends Backbone.Model
  validate: (attributes) ->
    unless attributes.data? && attributes.data != ""
      return "A message must be provided!"
