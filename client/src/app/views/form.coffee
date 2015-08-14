$ = require("jquery")
Marionette = require("backbone.marionette")
template = require("../templates/form.jade")
SiteModel = require("../models/site")

module.exports = Marionette.ItemView.extend(
  model: new SiteModel()
  template: template
  
  events:
    "submit form": "enterSite"
  
  ui:
    url: ".url"
    email: ".email"
    form: ".site-form"
  
  enterSite: (e) ->
    e.preventDefault()
    return unless @formIsValid()
    url = @ui.url.val().trim()
    email = @ui.email.val().trim()
    @model.save({ url: url },
      success: =>
        @ui.form.get(0).reset()
        @model.clear()
        location.hash = "sites"
    )

  formIsValid: ->
    valid = @validateForm()
    if valid
      @ui.url.removeClass("form-error")
      @$(".error").hide()
    else
      @ui.url.addClass("form-error")
      @$(".error").show()
    valid

  validateForm: ->
    @ui.url.val().trim().length > 0
)
