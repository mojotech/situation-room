$ = require("jquery")
Marionette = require("backbone.marionette")
StatusView = require("./status")
NoSitesView = require("./no-sites")

module.exports = Marionette.CompositeView.extend(
  childView: StatusView
  childViewContainer: "tbody"
  emptyView: NoSitesView
  template: require("../templates/list-statuses.jade")
)
