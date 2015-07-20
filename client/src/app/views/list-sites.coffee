$ = require('jquery')
Marionette = require('backbone.marionette')
SiteView = require('./site')
NoSitesView = require('./no-sites')
SiteCollection = require('../collections/site-collection')
template = require('../templates/list-sites.jade')

module.exports = Marionette.CompositeView.extend(
  collection: new SiteCollection()
  childView: SiteView
  childViewContainer: 'tbody'
  emptyView: NoSitesView
  template: template
  initialize: ->
    @collection.fetch({ reset: true })
)
