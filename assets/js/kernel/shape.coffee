class kernel.Shape extends EventEmitter
  points: []
  guides: []
  visibleGuides: false
  initialized: false
  # Treat these as read only after instantiation
  type: null

  _init: (opts) =>
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

  # True if the shape has all it's points defined
  fullyDefined: ->
    @points.length == requiredPointCount()

  requiredPointCount: ->
    switch type
      when "line" then 2
      when "circle" then 1
