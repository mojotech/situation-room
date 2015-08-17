Backbone = require("backbone")
Router = require("./router")
Marionette = require("backbone.marionette")

app = new Marionette.Application()

app.on "start", ->
  router = new Router()
  Backbone.history.start()

app.start()
