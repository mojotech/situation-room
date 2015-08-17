$ = require("jquery")
Backbone = require("backbone")
StatusModel = require("../models/status")

module.exports = Backbone.Collection.extend(
  model: StatusModel
  comparator: (model) ->
    -model.get("id")
)
