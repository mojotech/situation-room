Backbone = require("backbone")
Router = require("./router")
Marionette = require("backbone.marionette")

require("../styles/main.styl")

app = new Marionette.Application()

app.on "start", ->
  router = new Router()
  Backbone.history.start()

app.start()
