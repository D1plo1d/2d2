class SvgSketch

  constructor: ->
    @$svg = $('.canvas')
    @_draw = new SVG(@$svg[0]).interactive()
    @$svg.removeAttr("height")

    @groups = []
    attrs = ['stroke-dasharray', 'stroke-width']
    for k in ["text", "shape", "guide"]
      @groups[k] = @_draw.group(scaled: k != 'text', unscaledAttrs: attrs, class: "#{k}-group")
    @_zoomedGroups = Object.reject(@groups, "text")

  # Not to be included in Lib

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
    @_draw.redraw()


sketch = new SvgSketch()

sketch.test()
# TODO: scrolling

#sketch.zoom(0.5)
