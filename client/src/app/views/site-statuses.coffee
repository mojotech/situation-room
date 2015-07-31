$ = require('jquery')
Marionette = require('backbone.marionette')
template = require('../templates/list-statuses.jade')
StatusView = require('./status')
NoSitesView = require('./no-sites')

module.exports = Marionette.CompositeView.extend(
  childView: StatusView
  childViewContainer: 'tbody'
  emptyView: NoSitesView
  template: template
)
