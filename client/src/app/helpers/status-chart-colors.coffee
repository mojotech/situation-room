statusColors = [
  {
    code: 200
    chartColors : {
      color: "#248d24"
      highlight: "#2db42d"
      label: "200 - OK"
    }
  }
  {
    code: 301
    chartColors : {
      color: "#b8d000"
      highlight: "#e2ff00"
      label: "301 - Moved Permanently"
    }
  }
  {
    code: 302
    chartColors : {
      color: "#ddb400"
      highlight: "#dd0"
      label: "302 - Moved Temporarily"
    }
  }
  {
    code: 400
    chartColors : {
      color: "#800000"
      highlight: "#900"
      label: "400 - Bad Request"
    }
  }
  {
    code: 401
    chartColors : {
      color: "#a10000"
      highlight: "#c93e3e"
      label: "401 - Unauthorized"
    }
  }
  {
    code: 403
    chartColors : {
      color: "#ab1515"
      highlight: "#e83f3f"
      label: "403 - Forbidden"
    }
  }
  {
    code: 404
    chartColors : {
      color: "#b00"
      highlight: "#ed1b24"
      label: "404 - Not found"
    }
  }
  {
    code: 500
    chartColors : {
      color: "#0500a3"
      highlight: "#4a45cc"
      label: "500 - Internal Server Error"
    }
  }
  {
    code: 502
    chartColors : {
      color: "#0700d1"
      highlight: "#7976de"
      label: "502 - Bad Gateway"
    }
  }
  {
    code: 503
    chartColors : {
      color: "#000d6e"
      highlight: "#2c40d4"
      label: "503 - Service Unavailable"
    }
  }
]

findColorByCode = (code) ->
  chartColors = {}
  statusColors.forEach( (status) ->
    chartColors = status.chartColors if status.code is code
    return
  )
  return chartColors

module.exports =
  statusColors: statusColors
  findColorByCode: findColorByCode
