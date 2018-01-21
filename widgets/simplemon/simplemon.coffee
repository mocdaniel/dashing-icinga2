class Dashing.Simplemon extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  ready: ->
    #setInterval(@checkUpdate, 100)

  onData: (data) ->
    if data.color
      # clear existing "color-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bcolor-\S+/g, ''
      # add new class
      $(@get('node')).addClass "color-#{data.color}"

  checkUpdate: =>
    if updatedAt = @get('updatedAt')
      timestamp = new Date(updatedAt * 1000)
      now = new Date()
      diff = now.getTime() - timestamp.getTime()
      if diff > 30000
        @onData({color:'grey'})
