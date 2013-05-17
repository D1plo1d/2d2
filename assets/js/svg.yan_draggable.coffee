SVG.extend SVG.Element, draggable: (parent, position = {x: 0, y: 0}) ->
  _start = {x: 0, y: 0}
  _self = @

  _init = ->
    $(_self.node).hammer()
      .on("touchstart dragstart", _onTouchStart)
      .on("drag", _onDrag)
      # http://stackoverflow.com/a/11613327/386193
      .on 'touchstart touchend touchmove drag pinch', _squashEvents

  _onTouchStart = (e) ->
    g = e.gesture
    for k in ['x', 'y']
      _start[k] = position[k]

  _onDrag = (e) ->
    _self.front()
    for k in ['x', 'y']
      delta = e.gesture["delta#{k.toUpperCase()}"]
      position[k] = delta / (parent.zoom?() || 1)  + _start[k]
      _self["c#{k}"](position[k])

  _squashEvents = (e) ->
    e.stopPropagation()
    e.preventDefault()
    return false

  _init(@)
  return @