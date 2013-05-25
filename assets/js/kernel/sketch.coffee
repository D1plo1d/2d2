class kernel.Sketch extends EventEmitter
  # All the points in the sketch
  points: null
  # All the shapes in the sketch
  shapes: null
  # All the constraints in the sketch
  constraints: null
  # The currently selected points, shapes and constraints
  selected: null
  # The diff of inputs made since the previous constraint solver update
  _diffs: null

  constructor: (string) ->
    @[a] = [] for a in ['points', 'shapes', 'constraints', 'selected', '_diffs']
    deserialize(string) if string?

  add: (obj) ->
    type = switch obj.constructor
      when kernel.Shape then "shape"
      when kernel.Point then "point"
      when kernel.Constraint then "constraint"
    @["#{type}s"].push obj
    obj.sketch = @
    @_addDiffListener(type, obj) if type != "shape"
    obj.on "delete", @_onObjDelete.fill type
    @emit "add", obj, type

  _addDiffListener: (type, obj) ->
    id = @["#{type}s"].indexOf(obj)
    fn = @_onDiff.fill id: id, objectType: type
    obj.on "diff", fn

  _onDiff: (objInfo, diff) =>
    @_diffs.push Object.merge {}, objInfo, diff

  _onObjDelete: (type, obj) =>
    @["#{type}s"].remove obj

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
    @updateSelection()
    return true

  hasSelection: () ->
    @selected.length > 0

  updateSelection: () ->
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

  cancel: =>
    s.unselect() for s in @selected
    s.cancel() for s in @_selectedParentShapes()
    @selected = []
    @updateSelection()

  deleteSelection: ->
    @cancel()
    s.delete() for s in @_selectedParentShapes()

  # Sends the changes to the kernel since the last request to the constraint 
  # solver as a single, atomic change set.
  requestConstraintsUpdate: ->
    # Note: This is so that we can combine multiple inputs (such as on a 
    # touch screen) and create useful results without bashing the constraint 
    # solver with partial updates.

    # TODO: send the diff to the constraint solver

    # Resetting the diff
    @_diffs = []

  _receiveConstraintsUpdate: (diffs) ->
    console.log diffs

  serialize: () ->
    JSON.stringify
      meta: { version: "0.0.0 Mega-Beta" }
      shapes: ( shape.serialize() for shape in @shapes ).compact

  _deserialize: (string) ->
    JSON.parse(string)
    for i, opts of hash.shapes
      this[opts.shapeType](opts)
