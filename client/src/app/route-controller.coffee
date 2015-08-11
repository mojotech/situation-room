$ = require('jquery')
Marionette = require('backbone.marionette')
ListSitesView = require('./views/list-sites')
SiteStatusesView = require('./views/site-statuses')
SiteCollection = require('./collections/site-collection')
StatusCollection = require('./collections/status-collection')
FormView = require('./views/form')
SiteModel = require('./models/site')
Layout = require('./views/layout')
layout = new Layout()
layout.render()

showInRoot = (view) ->
  layout.root.show(view)

module.exports = Marionette.Object.extend(
  index: ->
    $('#content').empty()

  createSite: ->
    showInRoot(new FormView())

  listSites: ->
    siteCollection = new SiteCollection()
    siteCollection.fetch(
      success: ->
        showInRoot(new ListSitesView(collection: siteCollection))
    )

  viewSite: (id) ->
    statusCollection = new StatusCollection()
    statusCollection.url = "/sites/#{id}/checks"
    statusCollection.fetch(
      success: ->
        showInRoot(new SiteStatusesView(collection: statusCollection))
    )
)
