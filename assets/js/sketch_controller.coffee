class SketchController extends EventEmitter

  constructor: ->
    @$svg = $('.canvas')
    @_draw = new SVG(@$svg[0]).interactive()
    @$svg.removeAttr("height")

    @groups = []
    attrs = ['stroke-dasharray', 'stroke-width']
    for k in ["text", "shape", "guide"]
      @groups[k] = @_draw.group scaled: k != 'text', unscaledAttrs: attrs, class: "#{k}-group"

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
    point = @groups.shape.circle(10)
      .move(500-5, 150-5)
      .attr class: "implicit-point"

    @groups.guide.line(-500, 0, 500, 0)
    @_draw.redraw()



  # Controller
  # ==================================
  _initController: ->

    this.element.mouseup   (e) => $(e.target).trigger "sketchmouseup",   @_$vMouse(e)
    this.element.mousedown (e) => $(e.target).trigger "sketchmousedown", @_$vMouse(e)
    this.element.mousemove (e) => $(e.target).trigger "sketchmousemove", @_$vMouse(e)

    this.element.bind "sketchmousedown", => @unselect()
    #this.$svg.draggable()

    this._mouseInit()
    #TODO: keyboard init will go here
    this._keyboardInit()

  # Keyboard interactions
  # -------------------------------

  _keyboardInit: ->
    # Delete and Cancel
    $(document).bind "keyup", "del", => @delete()
    $(document).bind "keyup", "esc", => @cancel()

    # New
    $(document).bind "keydown", "ctrl+n", (e) =>
      @reset()
      e.stopPropagation( )  
      e.preventDefault( )
      return false

    # Zoom
    $(document).bind "keypress", "+", =>
      @zoom("++")
      return false
    $(document).bind "keypress", "-", =>
      @zoom("--")
      return false
    @$svg.mousewheel _.throttle ( (a,b,c,d) => @_mouseWheel(a,b,c,d) ), 20


    # TODO: move this to shape or line?
    @shift = false
    $(document).bind "keydown", "shift", => @shift = true
    $(document).bind "keyup", "shift", => @shift = false

    $(@$svg).bind "aftercreate", (e) =>
      if @shift and e.shape.shapeType == "line"
        @line(points: [ e.shape.points[1] ])

  # Mouse interactions
  # -------------------------------

  # Calculates a sketch-relative position vector for mouse events accounting for translation and scaling
  _$vMouse: (e) ->
    top = @element.position().top
    # Determining if e is a jQuery Event object or a Raphael Vector object
    $vMouse = if e.target? then $V([e.pageX, e.pageY]) else e

    $vMouse = $vMouse.subtract($V [0, top])
    $vMouse = $vMouse.x(@_zoom.positionMultiplier)
    $vMouse = $vMouse.subtract($V @_position)
    $vMouse = $vMouse.add($V @_zoom.positionOffset)

  _mouseWheel: (event, delta, deltaX, deltaY) ->
    @zoom( @_zoom.mouseWheelIncrement * delta )
    event.preventDefault()
    return true

  _mouseStart: (e) ->
    @_dragging = $(e.target).is("svg")
    @_$vSketchClick =  @_$vMouse(e)


  _mouseDrag: (e) ->
    return true unless @_dragging == true
    # translate the sketch by [deltaX, deltaY]
    p = @_$vMouse(e).subtract(@_$vSketchClick).add($V @_position)
    @set_position p.elements

