class Dashing.Clock extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    zone = @get('timezone')
    optionsDate = { timeZone: zone, weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' };
    optionsTime = { timeZone: zone, hour: '2-digit', minute: '2-digit'};

    date = new Date().toLocaleDateString('en-US', optionsDate);
    time = new Date().toLocaleTimeString('en-US', optionsTime);

    @set('time', time)
    @set('date', date)
    @set('title', @get('title'))
