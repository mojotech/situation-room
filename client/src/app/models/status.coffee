Backbone = require('backbone')

module.exports = Backbone.Model.extend(
  urlRoot: "/sites/#{@id}/checks"
)
