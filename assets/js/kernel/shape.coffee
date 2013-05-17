class kernel.Shape extends EventEmitter
  points: []
  guides: []
  visibleGuides: false
  selected: false
  initialized: false
  # Treat these as read only after instantiation
  type: null

  constructor: (opts) ->
    # Move the contruction of this shape to the end of the event queue
    # so that event listeners can be added after instantiation.
    setTimeout @_init, 0

  _init: =>
    @emit "beforeInitialize"
    @[k] = v || @[k] for k, v of opts

    # setup each predefined point
    @add p for p in @points

    initialized = true
    @emit "initialize"

  add: (p, eventsOnly = false) ->
    @emit "beforeAddPoint", p
    points.push p unless eventsOnly
    @emit "fullyDefine" if @fullyDefined()
    @emit "addPoint", p

  showGuides: (value = true) ->
    @_updateAttr "visibleGuides", value, false: "hideGuides", true: "showGuides"

  select: (value = true) ->
    @_updateAttr "selected", value, false: "unselect", true: "select"

  unselect: ->
    @select false

  delete: ->
    @emit "delete"

  _updateAttr: (attr, value, eventNames) ->
    return if @[attr] == value
    @[attr] = value
    @emit eventNames[value.toString()]

  # True if the shape has all it's points defined
  fullyDefined: ->
    @points.length == requiredPointCount()

  requiredPointCount: ->
    switch type
      when "line" then 2
      when "circle" then 1
      when "point" then 0
