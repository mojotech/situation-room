$ = require('jquery')
Marionette = require('backbone.marionette')
StatusView = require('./status')
StatusCollection = require('../collections/status-collection')
NoSitesView = require('./no-sites')
UpdateTimes = require('../behaviors/update-times-interval')

module.exports = Marionette.CompositeView.extend(
  childView: StatusView
  childViewContainer: 'tbody'
  emptyView: NoSitesView
  template: require('../templates/list-statuses.jade')

  behaviors: {
    UpdateTimes: {
      behaviorClass: UpdateTimes
    }
  }
)
