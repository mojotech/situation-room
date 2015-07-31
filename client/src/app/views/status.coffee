$ = require('jquery')
Marionette = require('backbone.marionette')
moment = require('moment')
StatusModel = require('../models/status')
template = require('../templates/status.jade')

module.exports = Marionette.ItemView.extend(
  model: new StatusModel({ parse: true })
  tagName: 'tr'
  template: template

  templateHelpers: ->
    formattedTime: moment(new Date(@model.get('createdAt'))).fromNow()
)
