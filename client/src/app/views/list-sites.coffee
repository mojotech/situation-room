$ = require('jquery')
Marionette = require('backbone.marionette')
SiteView = require('./site')
NoSitesView = require('./no-sites')
UpdateTimes = require('../behaviors/update-times-interval')

module.exports = Marionette.CompositeView.extend(
  childView: SiteView
  childViewContainer: 'tbody'
  emptyView: NoSitesView
  template: require('../templates/list-sites.jade')

  behaviors: {
    UpdateTimes: {
      behaviorClass: UpdateTimes
    }
  }
)
