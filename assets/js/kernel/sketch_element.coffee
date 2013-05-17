class kernel.SketchElement extends EventEmitter
  selected: false

  constructor: (opts) ->
    # Move the contruction of this element to the end of the event queue
    # so that event listeners can be added after instantiation.
    setTimeout @_init.fill(opts), 0

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
