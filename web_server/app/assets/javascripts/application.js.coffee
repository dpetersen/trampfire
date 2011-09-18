#= require vendor/load_orderer
#= require_self
#= require_directory ./models
#= require_directory ./collections
#= require_directory ./views
#= require_directory ./lib

Trampfire ?= {}

jQuery ->
  Trampfire.App = new Trampfire.TrampfireView
