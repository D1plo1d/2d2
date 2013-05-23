class kernel.Shape extends kernel.SketchElement
  points: []
  guides: []
  visibleGuides: false
  initialized: false
  # Treat these as read only after instantiation
  type: null

  constructor: ->
    super
    @on "addPoint", @_onAddPoint
    @on "removePoint", @_onRemovePoint
    @on "unselect", @_onUnselect
    @on "delete", @_onDelete

    # setup each predefined point
    @add p for p in @points

  _init: (opts) =>
    @emit "beforeInitialize"

    initialized = true
    @emit "initialize"

  add: (p, eventsOnly = false) ->
    @emit "beforeAddPoint", p
    @points.push p unless eventsOnly
    console.log "point added sir!"
    console.log @isFullyDefined()
    @emit "fullyDefine" if @isFullyDefined()
    @emit "addPoint", p

  showGuides: (value = true) ->
    @_updateAttr "visibleGuides", value, false: "hideGuides", true: "showGuides"

  _onDelete: ->
    point.delete(originalTarget) for point in @points


  # True if the shape has all it's points defined
  isFullyDefined: ->
    @points.length == @requiredPointCount()

  requiredPointCount: ->
    switch @type
      when "line" then 2
      when "circle" then 1

  # cancels the current operation on this shape (if any)
  _onUnselect: =>
    @delete() unless @isFullyDefined()

  _onAddPoint: (point) =>
    @_togglePointEvents point, "on"

  _onRemovePoint: (point) =>
    @_togglePointEvents point, "off"

  _togglePointEvents: (point, toggle) ->
    # point deletion -> deletes this shape as well
    point[toggle]("beforedelete", @_onBeforePointDelete.fill(point))
    # point merging -> switch over to the new point
    point[toggle]("merge", @_onPointMerge.fill(point))

  _onPointMerge: (point, e) =>
    return unless point == e.deadPoint
    @points[@points.indexOf(point)] = e.mergedPoint
    @emit "removePoint", e.deadPoint
    @emit "addPoint", e.mergedPoint

  _onBeforePointDelete: (point, originalTarget) =>
    return @delete() if @_deleting or @points.include originalTarget
    # if the original target of deletion is a unrelated shape containing a 
    # shared point then prevent the shared point from being deleted. It is 
    # still required by this shape.
    point.preventDeletion()
