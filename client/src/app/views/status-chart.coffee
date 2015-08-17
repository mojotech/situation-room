$ = require("jquery")
_ = require("lodash")
Marionette = require("backbone.marionette")
statusChartColors = require("../helpers/status-chart-colors")

module.exports = Marionette.ItemView.extend(
  template: require("../templates/chart.jade")

  onShow: ->
    @makeChart(@chartContext("status-chart"), @chartData(), @chartOptions())

  templateHelpers: ->
    siteKey: @collection.url.split('/')[2]
    current: @collection.at(0).get('response')

  chartContext: (canvasId) ->
    document.getElementById(canvasId).getContext("2d")

  chartOptions: ->
    segmentStrokeWidth: 1
    animationEasing: "linear"

  chartData: ->
    statuses = _.uniq(@collection.pluck('response'))
    data = []

    statuses.forEach( (status) =>
      data.push(
        _.extend(statusChartColors.findColorByCode(status),
          { value: @collection.where(response: status).length }
        )
      )
    )

    return data

  makeChart: (ctx, data, options) ->
    new Chart(ctx).Pie(data, options)
)
