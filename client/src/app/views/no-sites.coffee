$ = require('jquery')
Marionette = require('backbone.marionette')
SiteModel = require('../models/site')

module.exports = Marionette.ItemView.extend(
  template: require('../templates/no-sites.jade')
)
