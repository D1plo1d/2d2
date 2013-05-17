class @SketchController extends EventEmitter
  sketch: null
  groups: []
  _draw: null

  constructor: (@sketch) ->
    console.log "cool"
    @_initSVG()
    @sketch.on "add", @_onAdd
    @enable()
    # Demo BS
    @test()

  _initSVG: ->
    @$svg = $('.canvas')
    @_draw = new SVG(@$svg[0]).interactive()
    @$svg.removeAttr("height")
    # Initializing the groups
    attrs = ['stroke-dasharray', 'stroke-width']
    for k in ["text", "shape", "guide"]
      @groups[k] = @_draw.group scaled: k != 'text', unscaledAttrs: attrs, class: "#{k}-group"
      # @groups[k] = @_draw.group scaled: true, unscaledAttrs: attrs, class: "#{k}-group"

  _keyboardEvents: -> @__keyboardEvents ?= [
    # Delete and Cancel
    ["keyup", null, "del", @sketch.deleteSelection],
    ["keyup", null, "esc", @sketch.cancel],
    # Zoom
    ["keypress", null, "+", @_draw.incrementZoom.fill(+0.1)],
    ["keypress", null, "-", @_draw.incrementZoom.fill(-0.1)]]

  _onAdd: (obj, type) =>
    console.log "#{type.capitalize()}Controller"
    new window["#{type.capitalize()}Controller"](obj, @)

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
    # point = @groups.shape.circle(10)
    #   .move(500-5, 150-5)
    #   .attr class: "implicit-point"
    @sketch.add new kernel.Point()

    @groups.guide.line(-500, 0, 500, 0)
    @_draw.redraw()

  # Turn keyboard events on or off
  enable: (enable = true) ->
    return if @enabled == enable
    @enabled = enable
    onOrOff = if enable then "on" else "off"

    for args in @_keyboardEvents()
      args = [args[0], args[2]] if !enable
      $(document)[onOrOff](args[0], args[1], args[2], args[3])

