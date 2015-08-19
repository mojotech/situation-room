$ = require('jquery')
moment = require('moment')
Marionette = require('backbone.marionette')
StatusModel = require('../models/status')

module.exports = Marionette.ItemView.extend(
  model: new StatusModel({ parse: true })
  tagName: 'tr'
  template: require('../templates/status.jade')

  templateHelpers: ->
    formattedTime: moment(new Date(@model.get('createdAt'))).fromNow()
)
