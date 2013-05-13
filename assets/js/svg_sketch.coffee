class SvgSketch
  _zoomLevel: 1
  _position: [0, 0]
  _dimension: {x: 0, y: 0}

  constructor: ->
    @$svg = $('.canvas')
    @_draw = SVG @$svg[0]

    @$svg
      .hammer()
      .removeAttr("height")
      .on("mousewheel", @_onMouseWheel)
      .on("touchstart dragstart", @_onTouchStart)
      .on("drag", @_onDrag)
      .on("pinch", @_onPinch)
      .on('touchstart touchend touchmove', @_chromeDragFix)

    @groups = []
    for k in ["text", "shape", "guide"]
      @groups[k] = @_draw.group()
        .attr(class: "#{k}-group")
    @_zoomedGroups = Object.reject(@groups, "text")

    @_onResize()
    $(window).on "resize", @_onResize

  _onMouseWheel: (e, delta, deltaX, deltaY) =>
    @_zoomLevel *= 1+deltaY/1000
    @_updateZoom()
    e.preventDefault()

  _onTouchStart: (e) =>
    console.log "touch start"
    @_fingersChangeHandler e, true
    # console.log e

  _fingersChangeHandler: (e, resetZoom = false) =>
    center = e.gesture?.center || e.originalEvent.touches[0]
    @_touchStart = 
      pageXY: [center.pageX, center.pageY]
      zoomLevel: if resetZoom then @_zoomLevel else @_touchStart?.zoomLevel
      position: @_position.clone()
      touches: e.gesture?.touches?.length
    console.log @_touchStart

  _onPinch: (e) =>
    console.log e
    @_zoomLevel = e.gesture.scale * @_touchStart.zoomLevel
    @_updateDrag(e)
    @_updateZoom()

  _chromeDragFix: (e) =>
    # http://stackoverflow.com/a/11613327/386193
    e.preventDefault()

  _onDrag: (e) =>
    @_updateDrag(e)

  _updateDrag: (e) ->
    if @_touchStart.touches != e.gesture?.touches?.length
      @_fingersChangeHandler(e)
    touch = e.gesture?.center || e
    pageXY = [touch.pageX, touch.pageY]
    for i in [0,1]
      delta = pageXY[i] - @_touchStart.pageXY[i]
      @_position[i] = @_touchStart.position[i] + delta / @_zoomLevel
    @_updateTranslations()

  _updateZoom: () ->
    for k, group of @_zoomedGroups
      group.transform
        scaleX: @_zoomLevel
        scaleY: @_zoomLevel
    @groups.guide.style
      'stroke-dasharray': "#{4 / @_zoomLevel} #{4 / @_zoomLevel}"
      'stroke-width': 1/@_zoomLevel
    @groups.shape.style
      'stroke-width': 2/@_zoomLevel

    @groups.text.each (i, children) =>
      text = children[i]
      text.transform
        x: text.attr('x')*(@_zoomLevel - 1)
        y: text.attr('y')*(@_zoomLevel - 1)

    @_updateTranslations()

  _updateTranslations: () ->
    transform =
      x: @_dimensions.x / 2 + @_position[0]*@_zoomLevel
      y: @_dimensions.y / 2 + @_position[1]*@_zoomLevel

    for k, group of @groups
      group.transform transform


  _onResize: () =>
    @_dimensions = {x: @$svg.width(), y: @$svg.height()}

    @_draw.viewbox x: 0, y: 0, width: @_dimensions.x, height: @_dimensions.y
    @_updateTranslations()

  test: ->
    @text = @groups.text.text('NooooOOOOooooooooOOOOOoooo')
    @text = @groups.text.text('SVG.JS')
    @text.move(500, 150)
    @text.fill('#777')
    @text.font
      family: 'Source Sans Pro'
      size: 180
      anchor: 'middle'
      leading: 1

    @groups.shape.line(-500, 0, 500, 150)
    @groups.guide.line(-500, 0, 500, 0)
    @_onResize()


sketch = new SvgSketch()

sketch.test()
# TODO: scrolling

#sketch.zoom(0.5)
