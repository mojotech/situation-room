$ = require("jquery")
Marionette = require("backbone.marionette")
template = require("../templates/layout.jade")

module.exports = Marionette.LayoutView.extend(
  el: "body"
  template: template
  regions:
    "root": "#content"
)
