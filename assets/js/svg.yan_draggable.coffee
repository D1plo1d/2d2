SVG.extend SVG.Element, draggable: (parent, position = {x: 0, y: 0}) ->
  _start = {x: 0, y: 0, pageX: 0, pageY: 0}
  _self = @
  _externalDragging = false
  $svg = $(parent.node)
  $node = $(@.node)

  _init = ->
    $(_self.node).hammer()
      .on("touchstart mousedown", _onTouchStart)
      # http://stackoverflow.com/a/11613327/386193
      .on('dragstart touchstart touchend drag pinch', _squashEvents)

  _self.drag = ->
    _externalDragging = true
    # $svg.one "tap", _drop
    $(window).one "mousemove tap", _onExternalDragStart

  _onExternalDragStart = (e) ->
    _onTouchStart e, true

  _onTouchStart = (e, external = false) ->
    console.log "dragging?"
    if external
      svgPosition = $svg.position()
      svgPosition = x: svgPosition.left, y: svgPosition.top
      svgDimensions = x: $svg.width(), y: $svg.height()
      scrollPosition = parent.position()
      scrollPosition = {x: scrollPosition[0], y: scrollPosition[1]}

    for k, pageK of {x: 'pageX', y: 'pageY'}
      if external
        _start[k] = e[pageK] - svgDimensions[k]/2 - svgPosition[k] - scrollPosition[k]
      else
        _start[k] = position[k]
      _start[pageK] = e[pageK]

    $(document)
      .on("touchmove mousemove", _onTouchMove)
      .on("touchend mouseup", _onTouchEnd)

    if _externalDragging and !external
      _onTouchMove(e)
      _onTouchEnd(e)
      _externalDragging = false


  _onTouchMove = (e) ->
    _self.front()
    for k, pageK of {x: 'pageX', y: 'pageY'}
      delta = (e.touches?[0] || e)[pageK] - _start[pageK]
      position[k] = delta / (parent.zoom?() || 1)  + _start[k]
      _self["c#{k}"](position[k])
    $node.trigger "yan.drag"

  _onTouchEnd = (e) ->
    $(document)
      .off("touchmove mousemove", _onTouchMove)
      .off("touchend mouseup", _onTouchEnd)

  _squashEvents = (e) ->
    e.stopPropagation()
    e.preventDefault()
    return false

  _init(@)
  return @