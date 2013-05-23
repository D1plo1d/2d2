# The shared class for all shapes
class @ShapeController extends EventEmitter
  guideElements: []
  kernelElement: null
  svgElement: null
  svgType: ""

  constructor: (@kernelElement, @parent) ->
    @sketch = @parent.sketch
    @draw = @parent.draw

    @kernelElement
      .on("fullyDefine", @_onFullyDefine)
      .on("beforeDelete", @_onBeforeDelete)
      .on("addPoint", @_onAddPoint)
      .on("removePoint", @_onRemovePoint)

    fullyDefined = @kernelElement.isFullyDefined()

    # call the shape's create method with the ui flag for shape-specific
    # intialization
    @_create(fullyDefined)

    # predefined shape: set up the svg element
    @_initSvgElement() if fullyDefined

  # signals the end of the shapes creation
  _onFullyDefine: =>
    console.log "created #{@constructor.name}"

  _onBeforeDelete: =>
    @svgElement.remove() if @svgElement?

  _onAddPoint: (point) =>
    point.on("move", @_onPointMove)
    # if this shape is selected style the newly added point appropriately
    @sketch.updateSelection()

  _onRemovePoint: (point) =>
    point.off("move", @_onPointMove)

  _onPointMove: =>
    @render()

  # adds and and initializes a guide (a graphical element for shape 
  # constructing purposes) to this shape
  _addGuide: (guideElement) ->
    @guides.push guideElement
    return guideElement

  render: ->
    console.log "render"
    # update the element only if it and all it's points exist
    @svgElement.show().attr @_attrs() if @svgElement?

  _attrs: ->
    throw "the shape controller _attrs method must be overwritten"

  _addNthPoint: (n) =>
    console.log "adding #{n}"
    point = new kernel.Point()
    @sketch.add point
    @kernelElement.add point
    point.on "place", @_addNthPoint.fill(n+1)

  # gets updated svg attributes as a hash.
  # The attributes should be in the order as they are passed to the elements constructor.
  # _attrs: -> throw "you need to overwride the _attrs function for your shape!"

  # sets this shapes element to a new element with given attributes
  # (optional) and initializes its event listeners and properties
  # _initSvgElement: (attrs) ->
  #   return if @_svgElementInitialized == true
  #   @_svgElementInitialized = true
  #   # if no element exists, use the provide options or the _attr() method to generate attributes 
  #   # for a new element
  #   # unless @element?
  #   #   attrs = @_attrs() unless attrs?
  #   #   @element = @sketch.paper[@raphaelType].apply( @sketch.paper, _.values( attrs ) )

  #   # move the shape behind the points
  #   @svgElement.toBack()

  #   # store the $node variable for the element
  #   @$node = $(@svgElement.node)
  #   if @svgType == "text" and this.shapeType == "point"
  #     @$node = $(@$node).find("tspan")
  #   @$node.addClass(this.shapeType)

  #   # if this shape is selected style it appropriately
  #   @sketch.updateSelection()
