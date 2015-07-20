$ = require('jquery')
Backbone = require('backbone')
SiteModel = require('../models/site')

module.exports = Backbone.Collection.extend(
  model: SiteModel
  url: '/sites'
)
