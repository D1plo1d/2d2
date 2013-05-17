# The shared class for all shapes
class @PointController extends EventEmitter
  parent: null # reference to the sketch controller
  kernelElement: null
  svgElement: null
  dragging: false
  svgType: "path"

  constructor: (@kernelElement, @parent) ->
    @svgElement = @parent.groups.points[@svgType]("M0,0L0,0")
      .draggable(@parent._draw)
      .attr class: "implicit-point"
    @svgElement[k] @kernelElement[k] for k in ['x', 'y']
