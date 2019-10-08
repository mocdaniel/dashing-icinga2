class Dashing.Chartjs extends Dashing.Widget

  constructor: ->
    super
    @id = @get("id")
    @type = @get("type")
    @header = @get("header")
    @labels = @get("labels") && @get("labels").split(",")
    @options = @get("options") || {}

    if @type == "scatter"
      @datasets = @get("datasets")
    else
      @datasets = @get("datasets") && @get("datasets").split(",")

    @colorNames = @get("colornames") && @get("colornames").split(",")

  ready: ->
    @draw()

  onData: (data) ->
    @type = data.type || @type
    @header = data.header || @header
    @labels = data.labels || @labels
    @options = data.options || @options
    @datasets = data.datasets || @datasets
    @colorNames = data.colorNames || @colorNames

    @draw()

  draw: ->
    switch @type
      when "pie", "doughnut", "polarArea"
        @circularChart @id,
          type: @type,
          labels: @labels,
          colors: @colorNames,
          datasets: @datasets,
          options: @options

      when "line", "bar", "horizontalBar", "radar", "scatter"
        @linearChart @id,
          type: @type,
          header: @header,
          labels: @labels,
          colors: @colorNames,
          datasets: @datasets,
          options: @options

      else
        return

  circularChart: (id, { type, labels, colors, datasets, options }) ->
    data = @merge labels: labels, datasets: [@merge data: datasets, @colors(colors)]
    new Chart(document.getElementById(id), { type: type, data: data }, options)

  linearChart: (id, { type, labels, header, colors, datasets, options }) ->
    data = @merge labels: labels, datasets: [@merge(@colors(colors), label: header, data: datasets)]
    new Chart(document.getElementById(id), { type: type, data: data }, options)

  merge: (xs...) =>
    if xs?.length > 0
      @tap {}, (m) -> m[k] = v for k, v of x for x in xs

  tap: (o, fn) -> fn(o); o

  colorCode: ->
    aqua: "0, 255, 255"
    black: "0, 0, 0"
    blue: "151, 187, 205"
    cyan:  "0, 255, 255"
    darkgray: "77, 83, 96"
    fuschia: "255, 0, 255"
    gray: "128, 128, 128"
    green: "0, 128, 0"
    lightgray: "220, 220, 220"
    lime: "0, 255, 0"
    magenta: "255, 0, 255"
    maroon: "128, 0, 0"
    navy: "0, 0, 128"
    olive: "128, 128, 0"
    purple: "128, 0, 128"
    red: "255, 0, 0"
    silver: "192, 192, 192"
    teal: "0, 128, 128"
    white: "255, 255, 255"
    yellow: "255, 255, 0"

  colors: (colorNames) ->
    backgroundColor: colorNames.map (colorName) => @backgroundColor(colorName)
    borderColor: colorNames.map (colorName) => @borderColor(colorName)
    borderWidth: colorNames.map (colorName) -> 1
    pointBackgroundColor: colorNames.map (colorName) => @pointBackgroundColor(colorName)
    pointBorderColor: colorNames.map (colorName) => @pointBorderColor(colorName)
    pointHoverBackgroundColor: colorNames.map (colorName) => @pointHoverBackgroundColor(colorName)
    pointHoverBorderColor: colorNames.map (colorName) => @pointHoverBorderColor(colorName)

  backgroundColor: (colorName) -> "rgba(#{ @colorCode()[colorName] }, 0.2)"
  borderColor: (colorName) -> "rgba(#{ @colorCode()[colorName] }, 1)"
  pointBackgroundColor: (colorName) -> "rgba(#{ @colorCode()[colorName] }, 1)"
  pointBorderColor: (colorName) -> "rgba(#{ @colorCode()[colorName] }, 1)"
  pointHoverBackgroundColor: -> "fff"
  pointHoverBorderColor: (colorName) -> "rgba(#{ @colorCode()[colorName] }, 0.8)"

  circleColor: (colorName) ->
    backgroundColor: "rgba(#{ @colorCode()[colorName] }, 0.2)"
    borderColor: "rgba(#{ @colorCode()[colorName] }, 1)"
    borderWidth: 1
    hoverBackgroundColor: "#fff"
    hoverBorderColor: "rgba(#{ @colorCode()['blue'] },0.8)"
