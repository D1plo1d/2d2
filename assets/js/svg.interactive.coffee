SVG.Doc.prototype.interactive = -> new InteractiveSVG(@); @

class InteractiveSVG
  _zoomLevel: 1
  _position: [0, 0]
  _dimension: {x: 0, y: 0} # The width and height of the svg element
  _svgPageCoords: {}
  _groups: []

  constructor: (@_draw) ->
    @$svg = $(@_draw.node)
    @_draw.redraw = @_updateTranslations
    @_draw._group = @_draw.group
    @_draw.group = @group
    @_draw.incrementZoom = @incrementZoom
    @_draw.zoom = @zoom

    @_onResize()
    $(window).on "resize", @_onResize

    @$svg
      .hammer()
      .on("mousewheel", @_onMouseWheel)
      .on("touchstart dragstart", @_onTouchStart)
      .on("drag", @_onDrag)
      .on("pinch", @_onPinch)
      # http://stackoverflow.com/a/11613327/386193
      .on 'touchstart touchend touchmove', (e) -> e.preventDefault()


  # SVG Overrides

  group: (opts = scaled: true) =>
    g = group: @_draw._group(), opts: opts
    g.group.attr(class: opts.class) if opts.class?
    @_groups.push g
    @_initUnscaledCss g
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


  # Event Listeners

  _onTouchStart: (e) =>
    @_previousScale = 1
    @_fingersChangeHandler e, true

  _onMouseWheel: (e, delta, deltaX, deltaY) =>
    @_zoomLevel *= 1+deltaY/1000
    @_updateZoom()
    e.preventDefault()

  _onPinch: (e) =>
    # console.log e
    touch = e.gesture?.center
    touch = {x: touch.pageX, y: touch.pageY}
    deltaScale = e.gesture.scale - @_previousScale
    @_zoomLevel = e.gesture.scale * @_touchStart.zoomLevel

    for k, i in ['x', 'y']
      unscaledOffset = touch[k] - @_dimensions[k] / 2 - @_svgPageCoords[k]
      @_pinchOffset[i] += deltaScale * unscaledOffset / @_zoomLevel

    @_onDrag(e)
    @_updateZoom()
    @_previousScale = e.gesture.scale

  _onDrag: (e) =>
    # console.log "interactive start"
    # console.log e
    # console.log "interactive end"
    if @_touchStart.touches != e.gesture?.touches?.length
      @_fingersChangeHandler(e)
    touch = e.gesture?.center || e
    pageXY = [touch.pageX, touch.pageY]
    for i in [0,1]
      delta = pageXY[i] - @_touchStart.pageXY[i]
      @_position[i] = @_touchStart.position[i] + delta / @_zoomLevel - @_pinchOffset[i]
    @_updateTranslations()

  _onResize: () =>
    p = @$svg.position()
    @_svgPageCoords = {x: p.left, y: p.top}
    @_dimensions = {x: @$svg.width(), y: @$svg.height()}

    @_draw.viewbox x: 0, y: 0, width: @_dimensions.x, height: @_dimensions.y
    @_updateTranslations()


  # Internal Functions

  # Handles any time when the number of touches changes or a new touch starts
  _fingersChangeHandler: (e, resetZoom = false) =>
    center = e.gesture?.center || e.originalEvent.touches[0]
    @_touchStart = 
      pageXY: [center.pageX, center.pageY]
      zoomLevel: if resetZoom then @_zoomLevel else @_touchStart?.zoomLevel
      position: @_position.clone()
      touches: e.gesture?.touches?.length
    @_pinchOffset = [0,0]

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
