# The shared class for all shapes
class @PointController extends EventEmitter
  parent: null # reference to the sketch controller
  kernelElement: null
  svgElement: null
  dragging: false
  svgType: "path"

  constructor: (@kernelElement, @parent) ->
    @svgElement = @parent.groups.points[@svgType]("M0,0L0,0")
    @svgElement.attr(class: "implicit-point")

    @kernelElement.on "move", @_onMove

    @$node = $(@svgElement.node)
      .touchInterface(offset: @_dragOffset, center: "touch[0]")
      .on("drag2", @_onDrag)

    @_onMove()
    @initPlacement() unless @kernelElement.placed

  initPlacement: ->
    @svgElement.hide()
    @$node.touchInterface("startDragging")
    @$node.one "drag2", => @svgElement.show()
    @$node.one "dragend", => @kernelElement.place()

  _dragOffset: =>
    $svg = @parent.$svg

    svgPos = @parent.$svg.position()
    svgPos = [svgPos.left, svgPos.top]

    svgDimensions = [$svg.width(), $svg.height()]

    return ( svgPos[i] + svgDimensions[i]/2 for i in [0..1] )

  _onDrag: (e) =>
    e.stopPropagation()

    sketchPos = @parent.draw.position()
    zoom = @parent.draw.zoom()

    position = ( e.gesture.position[i] / zoom - sketchPos[i] for i in [0..1] )

    @kernelElement.move.apply @kernelElement, position

  _onMove: =>
    @svgElement[k] @kernelElement[k] for k in ['x', 'y']
