class kernel.Point extends kernel.SketchElement
  x: 0, y: 0
  placed: false

  place: () ->
    placed = true
    @emit "place"

  # Moves this point. If input is set to true (default) this move will be 
  # treated as input to the constraint solver and the constraints will 
  # orient themselves to anchor the point at the given position.
  # If anchor is set to false this is a constraint solver generated movement.
  move: (@x, @y, input = true, snapDistance = kernel.Point.snapDistance) ->
    @_snapToNearestPoint snapDistance if input and @sketch?
    @emit "move"
    return if input
    @emit "diff", type: "change", x: @x, y: @y

  # Sets the vectors elements to those of the nearest point within snapping 
  # distance or leaves them unchanged if there is no point close enough to 
  # snap to.
  #
  # return: the nearest snappable point or null if no point is close enough 
  # to snap to.
  _snapToNearestPoint: (snapDistance) ->
    @_coincidentPoint = null
    nearestDistance = Number.MAX_VALUE

    for p2 in @sketch.points
      # check that the other point is not this point
      continue if @ == p2

      # check if the other point is within snapping distance of this point and 
      # it is the nearest point
      distance = Math.sqrt( Math.pow(@x - p2.x, 2) + Math.pow(@y - p2.y, 2) )
      console.log p2
      console.log distance
      continue unless distance <= snapDistance and distance < nearestDistance

      nearestDistance = distance
      @_coincidentPoint = p2

    # if a nearby snappable point was discovered, snap to it and record it 
    return unless @_coincidentPoint?
    console.log "snapping to:"
    console.log @_coincidentPoint
    @[k] = @_coincidentPoint[k] for k in ['x', 'y']

  mergeCoincidentPoints: ->
    # @merge(@_coincidentPoint) if @_coincidentPoint?
    @coincidentPoint = null

  merge: (p2) ->
    return if p2.isDeleted() or @isDeleted()
    $nodes = $().add(p2.$node).add(@$node)
    for point in [@, p2]
      point.emit "merge", deadPoint: p2, mergedPoint: @
    p2.delete()

# Default snapping distance for all points
kernel.Point.snapDistance = 10
