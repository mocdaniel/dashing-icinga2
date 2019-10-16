class Dashing.Iframe extends Dashing.Widget

  ready: ->
    # This is fired when the widget is done being rendered
    $(@node).find(".iframe").attr('src', @get('src'))

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
    $(@node).find(".iframe").attr('src', data.src)
