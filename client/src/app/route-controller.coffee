$ = require("jquery")
Marionette = require("backbone.marionette")
ListSitesView = require("./views/list-sites")
SiteStatusesView = require("./views/site-statuses")
StatusCollection = require("./collections/status-collection")
FormView = require("./views/form")
SiteModel = require("./models/site")
Layout = require("./views/layout")
layout = new Layout()
layout.render()

showInRoot = (view) ->
  layout.root.show(view)

module.exports = Marionette.Object.extend(
  index: ->
    $("#content").empty()

  createSite: ->
    showInRoot(new FormView())

  listSites: ->
    showInRoot(new ListSitesView())

  viewSite: (id) ->
    statusCollection = new StatusCollection(key: id)
    statusCollection.url = "/sites/#{id}/checks"
    statusCollection.fetch(
      reset: true
      success: ->
        showInRoot(new SiteStatusesView(collection: statusCollection))
    )
)
