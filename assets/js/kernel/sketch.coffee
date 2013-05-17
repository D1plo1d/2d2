class kernel.Sketch extends EventEmitter
  # All the points in the sketch
  points: []
  # All the shapes in the sketch
  shapes: []
  # All the constraints in the sketch
  constraints: []
  # The currently selected points, shapes and constraints
  selected: []

  constructor: (string) ->
    deserialize(string) if string?

  add: (obj) ->
    type = switch obj.constructor
      when kernel.shape then "shape"
      when kernel.point then "point"
      when kernel.constraint then "constraint"
    @["#{type}s"].push obj
    @emit "add#{type}", obj, type

  select: (shape) ->
    # if the element is included in the selected shapes then
    # maintain the current selection
    return true if @selected.include shape
    # prevent selection if the current shape creation is not complete
    return false if !@selected.all created: false
    # kill the previous selections
    @cancel()
    # Select the new shape
    @selected = [shape]
    @_updateSelection()
    return true

  hasSelection: () ->
    @selected.length > 0

  _updateSelection: () ->
    newSelection = @selected.union(@_selectedChildPoints()).unique()
    s.select() unless @selected.include s for s in newSelection
    @selected = newSelection

  # every point belonging to another shape in the current selection
  _selectedChildPoints: ->
    ( s.points for s in @selected ).flatten().unique()

  # every shape in the current selection except points belonging to 
  # another shape in the current selection
  _selectedParentShapes: ->
    @selected.subtract @_selectedChildPoints()

  cancel: ->
    s.unselect() for s in @selected
    s.cancel() for s in @_selectedParentShapes()
    @selected = []
    @_updateSelection()

  deleteSelection: ->
    @cancel()
    s.delete() for s in @_selectedParentShapes()

  serialize: () ->
    JSON.stringify
      meta: { version: "0.0.0 Mega-Beta" }
      shapes: ( shape.serialize() for shape in @shapes ).compact

  _deserialize: (string) ->
    JSON.parse(string)
    for i, opts of hash.shapes
      this[opts.shapeType](opts)
