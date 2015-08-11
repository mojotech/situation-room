$ = require('jquery')
Marionette = require('backbone.marionette')

module.exports = Marionette.Behavior.extend(

  onRender: ->
    @view.statusInterval = setInterval ( => @updateCollection() ), 1000 * 60

  onDestroy: ->
    clearInterval(@view.statusInterval)

  updateCollection: ->
    @view.collection.fetch({ reset: true })
)
