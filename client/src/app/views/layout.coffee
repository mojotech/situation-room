$ = require("jquery")
Marionette = require("backbone.marionette")

module.exports = Marionette.LayoutView.extend(
  el: "body"
  template: require("../templates/layout.jade")
  regions:
    "root": "#content"
)
