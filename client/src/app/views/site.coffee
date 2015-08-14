$ = require("jquery")
moment = require("moment")
Marionette = require("backbone.marionette")
SiteModel = require("../models/site")

module.exports = Marionette.ItemView.extend(
  model: new SiteModel({ parse: true })
  tagName: "tr"
  template: require("../templates/site.jade")

  ui:
    destroy: ".delete"

  events:
    "click @ui.destroy": "confirmDelete"

  templateHelpers: ->
    formattedTime: moment(new Date(@model.get("createdAt"))).fromNow()

  confirmDelete: (e) ->
    e.preventDefault()
    e.stopPropagation()
    if confirm "Are you sure you want to remove this site?" then @model.destroy()
)
