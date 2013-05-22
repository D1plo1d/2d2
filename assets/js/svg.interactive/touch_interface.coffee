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
  _previousPinch: 1

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
      @_onTouchMove(e)
      e.stopImmediatePropagation()
      return false

  _resetStart: (e, triggerDragStart) ->
    @start =
      offset: @opts.offset(e) # the initial offset value
      coords: @_getCoords e # the screen coordinates of the touch
      touchCount: e.originalEvent.touches?.length # the number of fingers on the screen
      touches: e.originalEvent.touches
    @$el.trigger "dragstart", e if triggerDragStart
    @_onPinchStart() if @start.touchCount > 1

  _onPinchStart: (e) =>
    @_originalPinchDistance = @_getDistance(@start.touches[0], @start.touches[1])


  _onTouchMove: (e) =>
    @_resetStart e, @start? if !@start? or e.originalEvent.touches?.length != @start.touchCount
    scale = @opts.scale?() || 1
    coords = @_getCoords e
    console.log e
    console.log "coords:"
    console.log coords
    if e.originalEvent.touches?.length > 0
      touchScale = @_getScale @start.touches, e.originalEvent.touches
    gesture =
      position: ( coords[i] * scale - @start.offset[i] for i in [0..1] )
      start: @start
      pinch: touchScale || 1
      pinchDisplacement: (touchScale - 1) * @_originalPinchDistance
      pinchDelta: (touchScale || 1) - @_previousPinch

    if @opts.subtractMouseCoords
      gesture.position[i] -= @start.coords[i] * scale for i in [0..1]
    @_previousPinch = gesture.pinch

    e2 = $.Event("drag2")
    e2.gesture = gesture
    @$el.trigger e2
    e.preventDefault()
    e.stopImmediatePropagation()

  stopDragging: (e) =>
    @_toggleEvents "off"
    @start = null
    @$el.trigger "dragend", e

  _toggleEvents: (toggle) ->
    $(window)[toggle]("mousemove touchmove", @_onTouchMove)
    $(window)[toggle]("touchend mouseup", @stopDragging)

  # calculate the distance between two touches
  # @param   {Touch}     touch1
  # @param   {Touch}     touch2
  # @returns {Number}    distance
  _getDistance: (touch1, touch2) ->
    x = touch2.pageX - touch1.pageX
    y = touch2.pageY - touch1.pageY
    return Math.sqrt((x*x) + (y*y))

  # calculate the scale factor between two touchLists (fingers)
  # no scale is 1, and goes down to 0 when pinched together, and bigger when pinched out
  # @param   {Array}     start
  # @param   {Array}     end
  # @returns {Number}    scale
  _getScale: (start, end) ->
    # need two fingers...
    if(start.length >= 2 and end.length >= 2)
        return @_getDistance(end[0], end[1]) / @_getDistance(start[0], start[1]);
    return 1

  _getCoords: (e) ->
    touches = e.originalEvent?.touches
    if touches? and touches.length > 0
      if @opts.center = "touch[0]"
        return @_pageToArray touches[0]
      else
        return @_getCenter touches
    else
      return @_pageToArray e

  _getCenter: (touches) ->
    # if we are centering the touches, get their average position
    coords = [0,0]
    @_pageToArray(touch, coords) for touch in touches
    return ( c / touches.length for c in coords )

  _pageToArray: (touch, coords = [0, 0]) ->
    coords[i] += touch[k] for k, i in ["pageX", "pageY"]
    return coords
