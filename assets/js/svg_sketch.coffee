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
      .on("dragstart", @_onDragStart)
      .on("drag", @_onDrag)

    @groups = []
    for k in ["text", "shape", "guide"]
      @groups[k] = @_draw.group()
        .attr(class: "#{k}-group")

    @_onResize()
    $(window).on "resize", @_onResize


  _onMouseWheel: (e, delta, deltaX, deltaY) =>
    @_zoomLevel *= 1+deltaY/1000
    @_updateZoom()
    e.preventDefault()


  _onDragStart: (e) =>
    @_dragStart = @_position.clone()

  _onDrag: (e) =>
    delta = [e.gesture.deltaX, e.gesture.deltaY]
    @_position[i] = @_dragStart[i] + delta[i] / @_zoomLevel for i in [0,1]
    @_updateTranslations()



  _updateZoom: () ->
    for k in ["shape", "guide"]
      @groups[k].transform
        scaleX: @_zoomLevel
        scaleY: @_zoomLevel
    @groups.guide.style
      'stroke-dasharray': "#{4 / @_zoomLevel} #{4 / @_zoomLevel}"
      'stroke-width': 1/@_zoomLevel
    @groups.shape.style
      'stroke-width': 2/@_zoomLevel
    @_updateTranslations()

  _updateTranslations: () ->
    for k, group of @groups
      group.transform
        x: @_dimensions.x / 2 + @_position[0]*@_zoomLevel
        y: @_dimensions.y / 2 + @_position[1]*@_zoomLevel


  _onResize: () =>
    @_dimensions = {x: @$svg.width(), y: @$svg.height()}

    @_draw.viewbox x: 0, y: 0, width: @_dimensions.x, height: @_dimensions.y
    @_updateTranslations()

  test: ->
    # text = @groups.text.text('SVG.JS')
    # text.move(650, 40).fill('#777')
    # text.font
    #   family: 'Source Sans Pro'
    #   size: 180
    #   anchor: 'middle'
    #   leading: 1

    @groups.shape.line(-500, 0, 500, 150)
    @groups.guide.line(-500, 0, 500, 0)


sketch = new SvgSketch()

sketch.test()
# TODO: scrolling

#sketch.zoom(0.5)
