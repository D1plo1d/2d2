SVG.Doc.prototype.interactive = -> new InteractiveSVG(@); @
isMacLike = navigator.userAgent.match(/(Mac|iPhone|iPod|iPad)/i)?

class InteractiveSVG
  _zoomLevel: 1
  _position: [0, 0]
  _dimension: {x: 0, y: 0} # The width and height of the svg element
  _svgPageCoords: null
  _groups: []
  _previousDisplacement: 0

  constructor: (@_draw) ->
    @$svg = $(@_draw.node)
    @_draw.redraw = @_updateTranslations
    @_draw._group = @_draw.group
    @_draw.group = @group
    @_draw.incrementZoom = @incrementZoom
    @_draw.zoom = @zoom
    @_draw.position = @position
    @_draw.width = @width
    @_draw.height = @height
    @_draw.domPosition = @domPosition

    @_onResize()
    $(window).on "resize", @_onResize

    @$svg.touchInterface
      offset: @_dragOffset
      scale: @_dragScale
      center: "average"
      subtractMouseCoords: true

    @$svg
      .on("drag2", @_onDrag)
      .on("mousewheel", @_onMouseWheel)
      .on("dragstart", @_onDragStart)


  # SVG Overrides

  width: =>
    @_dimensions.x

  height: =>
    @_dimensions.y

  domPosition: =>
    @_svgPageCoords

  group: (opts = scaled: true) =>
    g = group: @_draw._group(), opts: opts
    g.group.attr(class: opts.class) if opts.class?
    @_groups.push g
    @_initUnscaledCss g
    @_updateZoom()
    return g.group

  incrementZoom: (inc) =>
    @_zoomLevel += inc
    @_updateZoom()
    return @_draw

  zoom: (val) =>
    if val?
      @_zoomLevel = val
      @_updateZoom()
      return @_draw
    else
      return @_zoomLevel

  position: (val) =>
    if val?
      @_position = val
      @_updateZoom()
      return @_draw
    else
      return @_position


  # Event Listeners

  # _onTouchStart: (e) =>
  #   @_previousScale = 1
  #   @_fingersChangeHandler e, true

  _onMouseWheel: (e, delta, deltaX, deltaY) =>
    deltaY = (if deltaY > 0 then +1 else -1) * 90 unless isMacLike
    @_zoomLevel *= 1+deltaY/1000

    @_updateZoom()
    e.preventDefault()

  _onPinch: (e) =>
    # console.log "pinch!"
    # console.log e
    # touch = e.gesture?.position
    # touch = {x: touch[0], y: touch[1]}
    @_zoomLevel = e.gesture.pinch * @_touchStart.zoomLevel

    for k, i in ['x', 'y']
      # unscaledOffset = touch[k] - @_dimensions[k] / 2 - @_svgPageCoords[k]
      # @_pinchOffset[i] = e.gesture.pinchDelta * unscaledOffset / @_zoomLevel
      # @_pinchOffset[i] = (1 - e.gesture.pinch) * @_touchStart.zoomLevel
      delta = (e.gesture.pinchDisplacement - @_previousDisplacement)
      @_pinchOffset[i] += delta / @_zoomLevel

    @_previousDisplacement = e.gesture.pinchDisplacement
    @_updateZoom()

  _onDrag: (e) =>
    e.stopPropagation()
    # console.log "interactive start"
    # console.log e
    # console.log "interactive end"
    # console.log "pinch offset:"
    # console.log @_pinchOffset

    # if @_touchStart.touches != e.gesture?.touches?.length
    #   @_fingersChangeHandler(e)
    # console.log e.gesture.position
    for i in [0,1]
      @_position[i] = e.gesture.position[i] - @_pinchOffset[i]
    @_updateTranslations()
    @_onPinch(e) if e.gesture.pinchDelta != 0

  _onResize: () =>
    unless @_svgPageCoords?
      p = @$svg.position()
      @_svgPageCoords = {x: p.left, y: p.top}
    # For some reason this won't work on firefox
    # @_dimensions = {x: @$svg.width(), y: @$svg.height()}
    # Very application specific, but it works in firefox. Fuck it.
    @_dimensions =
      x: $("body").width() - @_svgPageCoords.x
      y: $("body").height() - @_svgPageCoords.y

    @$svg.attr width: @_dimensions.x, height: @_dimensions.y
    @_draw.viewbox x: 0, y: 0, width: @_dimensions.x, height: @_dimensions.y
    @_updateTranslations()

  _onDragStart: (e, start) =>
    @_touchStart = zoomLevel: @_zoomLevel
    @_previousDisplacement = 0

  # Internal Functions

  _dragOffset: (e) =>
    @_pinchOffset = [0,0]
    offset = @_position.clone()
    offset[i] *= -1 for i in [0..1]
    # console.log offset
    return offset
    # @_touchStart.position[i] + delta / @_zoomLevel - @_pinchOffset[i]

  _dragScale: () =>
    1/@_zoomLevel

  # Handles any time when the number of touches changes or a new touch starts
  # _onResetDragStart: (e, start, resetZoom = false) =>
  #   center = e.gesture?.center || e.originalEvent.touches[0]
  #   @_touchStart = 
  #     pageXY: [center.pageX, center.pageY]
  #     zoomLevel: if resetZoom then @_zoomLevel else @_touchStart?.zoomLevel
  #     position: @_position.clone()
  #     touches: e.gesture?.touches?.length
  #   @_pinchOffset = [0,0]

  _updateZoom: () ->
    for g in @_groups
      group = g.group
      if g.opts.scaled
        # group.animate(300).transform scaleX: @_zoomLevel, scaleY: @_zoomLevel
        group.transform scaleX: @_zoomLevel, scaleY: @_zoomLevel
      else
        group.each (i, children) => @_updateChild children[i]

      @_updateUnscaledCss g

    @_updateTranslations()

  _updateChild: (el) ->
    # el.animate(300).transform
    el.transform
      x: el.attr('x')*(@_zoomLevel - 1)
      y: el.attr('y')*(@_zoomLevel - 1)

  _initUnscaledCss: (g) ->
    g.opts.unscaledAttrs ?= {}
    vals = g.initialVals = {}
    $group = $(g.group.node)
    for k in g.opts.unscaledAttrs
      css = $group.css k
      continue if css == "none" or !(css?)
      vals[k] = ( parseFloat(v) for v in css.split " " )

  _updateUnscaledCss: (g) ->
    style = {}

    for k in g.opts.unscaledAttrs
      continue unless g.initialVals[k]?
      style[k] = ( v / @_zoomLevel for v in g.initialVals[k] ).join(" ")

    $(g.group.node).css style

  _updateTranslations: () =>
    transform =
      x: @_dimensions.x / 2 + @_position[0]*@_zoomLevel
      y: @_dimensions.y / 2 + @_position[1]*@_zoomLevel

    g.group.transform transform for g in @_groups
