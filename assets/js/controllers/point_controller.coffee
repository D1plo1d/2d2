# The shared class for all shapes
class @PointController extends EventEmitter
  parent: null # reference to the sketch controller
  kernelElement: null
  svgElement: null
  dragging: false
  svgType: "circle"

  constructor: (@kernelElement, @parent) ->
    @svgElement = @parent.groups.shape[@svgType](10)
      .draggable(@parent._draw)
      .attr class: "implicit-point"
    @svgElement[k] @kernelElement[k] for k in ['x', 'y']
