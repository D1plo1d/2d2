$.fn.touchInterface = (opts) ->
  preExistingInterface = $(@).data("_touchInterface")
  if !preExistingInterface?
    new touchInterface($(@), opts)
  else if typeof(opts) == "string"
    preExistingInterface[opts]()
  else
    return preExistingInterface.offset
  return $(@)


class touchInterface
  start: null

  constructor: (@$el, @opts) ->
    @$el
      .data("_touchInterface", @)
      .on("touchstart mousedown", @startDragging)
      # http://stackoverflow.com/a/11613327/386193
      .on 'touchstart touchend touchmove', (e) -> e.preventDefault()

  startDragging: (e) =>
    @_toggleEvents "on"
    if e?
      @_resetStart e, true
      e.stopPropagation()

  _resetStart: (e, triggerDragStart) ->
    @start =
      offset: @opts.offset(e) # the initial offset value
      coords: @_getCoords e # the screen coordinates of the touch
      touchCount: e.touches?.length # the number of fingers on the screen
    @$el.trigger "dragstart", e if triggerDragStart


  _onTouchMove: (e) =>
    @_resetStart e, @start? if !@start? or e.touches?.length != @start.touchCount
    scale = @opts.scale?() || 1
    coords = @_getCoords e
    e = $.Event("drag2")
    e.gesture =
      position: ( coords[i] * scale - @start.offset[i] for i in [0..1] )
      # position: ( coords[i] - @start.offset[i] - @start.coords[i] for i in [0..1] )
      start: @start
    if @opts.subtractMouseCoords
      e.gesture.position[i] -= @start.coords[i] * scale for i in [0..1]
    @$el.trigger e

  stopDragging: (e) =>
    @_toggleEvents "off"
    @start = null

  _toggleEvents: (toggle) ->
    $(window)[toggle]("mousemove", @_onTouchMove)
    $(window)[toggle]("touchend mouseup", @stopDragging)


  _getCoords: (e) ->
    if e.touches? and e.touches.length > 0
      if opts.center = "touch[0]"
        return @_pageToArray e.touches[0]
      else
        # if we are centering the touches, get their average position
        coords = [0,0]
        @_pageToArray(touch, coords) for touch in e.touches
        return ( c / e.touches.length for c in coords )
    else
      return @_pageToArray e

  _pageToArray: (touch, coords = [0, 0]) ->
    coords[i] += touch[k] for k, i in ["pageX", "pageY"]
    return coords
