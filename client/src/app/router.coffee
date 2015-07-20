Marionette = require('backbone.marionette')
RouteController = require('./route-controller')

module.exports = Marionette.AppRouter.extend(
  controller: new RouteController()
  appRoutes:
    'sites/new': 'createSite'
    'sites': 'listSites'
    'sites/:id/checks': 'viewSite'
    '': 'index'
)
