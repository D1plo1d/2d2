# The shared class for all shapes
class @ShapeController extends EventEmitter
  shape: null
  guideElements: []
  element: null
  dragging: false
  svgType: ""

  constructor: (@sketch, @shape) ->
    # TODO, fix this so it's dynamic
    @shape
      .on("fullyDefine", @_onFullyDefine)
      .on("unselect", @_onUnselect)

    # true if the shape's parameters are not defined and thus we need to
    # build the object via the gui and user interaction
    ui = @shape.fullyDefined()

    # call the shape's create method with the ui flag for shape-specific intialization
    @_create(ui)

    # predefined shape: set up the svg element
    @_initElement() unless ui == true

  # signals the end of the shapes creation
  _onFullyDefine: ->
    return if @_created == true
    #console.log "created #{@shapeType}"
    @dragging = false
    @_created = true
    @sketch._shapes.push( this )
    @_event("aftercreate")

  # cancels the current operation on this shape (if any)
  _onUnselect: () ->
    @shape.delete() if @_created == false


  # deletes the shape. targetShape: the shape that was deleted that started this deletion chain.
  delete: (targetShape = this) ->
    return if @_deleting == true
    # notifying listeners of this shapes untimely demise if the node is created
    event = @_event("beforedelete", targetShape: targetShape)
    return if event.isDefaultPrevented()

    #console.log "deleting #{@shapeType}"
    @_deleting = true
    # delete any points that are deletable, ignore the ones that are still in use.
    point.delete(targetShape) for point in @points

    # deleting the shape and any points it may have
    @element.remove() if @element?
    @$node.remove() if @$node?
    @sketch._shapes = _.without(@sketch._shapes, this)
    @_afterDelete()

  _afterDelete: -> return null # custom deletion code goes here

  isDeleted: -> return @_deleting == true

  # adds and and initializes a guide (a graphical element for shape constructing purposes)
  # to this shape
  _addGuide: (guideElement) ->
    @guides.push guideElement
    $(guideElement.node).addClass("creation-guide")
    return guideElement


  # adds a point to this shape.
  # _addPoint() defaults to a implicit point, a hash or point can also be passed to override
  # this default.
  _addPoint: (point = type: "implicit") ->
    # creating a point from a hash
    point = @sketch.point(point) if point.type?

    # pushing the point to the points array if it is not already in it
    @points.push point unless _.include(this.points, point)

    @_initPointEvents(point)

    # if this shape is selected style the newly added point appropriately
    @sketch.updateSelection()

    return point


  _initPointEvents: (point) ->
    # point move event listeners
    point.$node.bind "move", @_pointMoved

    # point deletion -> deletes this shape as well
    point.$node.bind "beforedelete", @_pointBeforeDelete

    # point merging -> switch over to the new point
    point.$node.bind "merge", (e) =>
      index = _.indexOf(@points, e.deadPoint)
      return if index == -1
      @points[index] = e.mergedPoint
      @_initPointEvents( e.mergedPoint )


  _pointBeforeDelete: (e) =>
    return true if @_deleting == true
    # if a point of this shape is the original target of a deletion delete this shape
    if _.include(@points, e.targetShape)
      @delete()
      return true
    # if the original target of deletion is a unrelated shape containing a shared point then 
    # prevent the shared point from being deleted, it is still required by this shape.
    return false


  _pointMoved: (e) =>
      @_afterPointMove(e.point) if @_afterPointMove?

      # update the element only if it and all it's points exist
      if @points.length == @numberOfPoints and @element?
        @render()
      return true


  render: ->
    @element.attr @_attrs() if @_elementInitialized == true


  # gets updated raphael attributes as a hash.
  # The attributes should be in the order as they are passed to the elements constructor.
  _attrs: -> throw "you need to overwride the _attrs function for your shape!"


  _dragElement: -> return true
  _dropElement: -> return true


  _unselect: -> null
  _updateSelection: -> null


  # sets this shapes element to a new element with given attributes
  # (optional) and initializes its event listeners and properties
  _initElement: (attrs) ->
    return if @_elementInitialized == true
    @_elementInitialized = true
    # if no element exists, use the provide options or the _attr() method to generate attributes 
    # for a new element
    unless @element?
      attrs = @_attrs() unless attrs?
      @element = @sketch.paper[@raphaelType].apply( @sketch.paper, _.values( attrs ) )

    # move the shape behind the points
    this.element.toBack()

    # store the $node variable for the element
    @$node = $(@element.node)
    @$node = $(@$node).find("tspan") if @raphaelType == "text" and this.shapeType == "point"
    @$node.addClass(this.shapeType)

    # drag and drop event listeners
    $svg = this.sketch.$svg
    $svg.bind "sketchmousemove", (e, $vMouse) =>
      return true unless @dragging == true
      @_dragElement(e, $vMouse)
      return true

    # if this shape is selected style it appropriately
    @sketch.updateSelection()


    this.$node.bind "sketchmousedown", (e, $vMouse) =>
      return true unless @_created == true
      # prevent drag and drop if we are unable to select this shape
      return true unless @sketch.select(this)
      @dragging = true
      # wait 100ms to see if this is a click or a drag.
      _.delay @_delayedMouseDown, 100, $vMouse
      return false


    # ignore mouse downs if we are dragging the element
    # (so that we can click to place it and not accidently trigger svg dragging)
    @sketch.$svg.bind "sketchmousedown", (e, $vMouse) => return @dragging != true

    @sketch.$svg.bind "sketchmouseup", (e, $vMouse) =>
      return true unless @dragging == true
      @dragging = false
      @_dropElement()
      @$node.trigger("afterDrop", this) if @$node?
      return false


  _delayedMouseDown: ($vMouse) ->
    if @dragging == true
      @$node.trigger("beforeDrag", this) if @$node?
    else
      @$node.trigger "clickshape", $vMouse


  # Serializes this shape into a hash. Uses the _serialize to allow for shape-specific 
  # serialization.
  # By default this includes the object's points and options hash
  # (removing any x, y and points entries and replacing them with the shapes point array)
  # format: { options: {OBJECT_OPTIONS AND points: @points} }
  serialize: ->
    return null if @options["serialize"] == false
    obj_hash = {shapeType: @shapeType}
    # excluding the intial point values (because we're going to replace these with values from 
    # @points)
    for key, value of @options
      obj_hash[key] = value unless /x[0-9]?/.exec(key) == key or key == "points"
    # injecting the current point positions as x,y options
    if @points? and @points.length > 0
      for index, point of @points
        for axis_index, axis of ["x", "y"]
          obj_hash["#{axis}#{index}"] = point.$v.elements[axis_index]
    # injecting non-standard attributes into the options hash
    return @_serialize(obj_hash)


  _serialize: (obj_hash) -> obj_hash
