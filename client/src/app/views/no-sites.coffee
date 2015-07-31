$ = require('jquery')
Marionette = require('backbone.marionette')
SiteModel = require('../models/site')
template = require('../templates/no-sites.jade')

module.exports = Marionette.ItemView.extend(
  template: template
)
