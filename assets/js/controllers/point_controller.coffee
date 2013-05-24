# The shared class for all shapes
class @PointController extends EventEmitter
  parent: null # reference to the sketch controller
  kernelElement: null
  svgElement: null
  dragging: false
  svgType: "path"

  constructor: (@kernelElement, @parent) ->
    @sketch = @parent.sketch
    @draw = @parent.draw

    @svgElement = @parent.groups.points[@svgType]("M0,0L0,0")
    @svgElement.attr(class: "implicit-point")

    @kernelElement
      .on("move", @_onMove)
      .on("delete", @_onDelete)

    @$node = $(@svgElement.node)
      .touchInterface(offset: @_dragOffset, center: "touch[0]")
      .on("dragstart", @_onDragStart)
      .on("drag2", @_onDrag)
      .on("dragend", @_onDragEnd)

    @_onMove()
    @initPlacement() unless @kernelElement.placed

  initPlacement: ->
    @svgElement.hide()
    @$node.touchInterface("startDragging")
    @_onDragStart()
    @$node.one "drag2", => @svgElement.show()
    @$node.one "dragend", => @kernelElement.place()

  _dragOffset: =>
    $svg = @parent.$svg

    svgPos = @parent.$svg.position()
    svgPos = [svgPos.left, svgPos.top]

    svgDimensions = [$svg.width(), $svg.height()]

    return ( svgPos[i] + svgDimensions[i]/2 for i in [0..1] )

  _onDragStart: =>
    console.log "starting the fucking drag"
    console.log @svgElement
    @svgElement.attr("data-selected", true).front()

  _onDrag: (e) =>
    e.stopPropagation()

    sketchPos = @parent.draw.position()
    zoom = @parent.draw.zoom()

    position = ( e.gesture.position[i] / zoom - sketchPos[i] for i in [0..1] )

    snapDistance = kernel.Point.snapDistance * @draw.zoom()
    @kernelElement.move position[0],position[1], true, snapDistance

  _onDragEnd: =>
    @kernelElement.mergeCoincidentPoints()
    @$node.attr("data-selected", null)

  _onMove: =>
    @svgElement[k] @kernelElement[k] for k in ['x', 'y']

  _onDelete: =>
    @$node.remove()
    @svgElement.remove()
    @$node = null
    @svgElement = null
