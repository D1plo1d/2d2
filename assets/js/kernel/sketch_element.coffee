class kernel.SketchElement extends EventEmitter
  selected: false

  constructor: (opts) ->
    @[k] = v || @[k] for k, v of opts

    # Move the contruction of this element to the end of the event queue
    # so that event listeners can be added after instantiation.
    setTimeout @_init.fill(opts), 0

  select: (value = true) ->
    @_updateAttr "selected", value, false: "unselect", true: "select"

  unselect: ->
    @select false

  _updateAttr: (attr, value, eventNames) ->
    return if @[attr] == value
    @[attr] = value
    @emit eventNames[value.toString()]

  # Deletes the sketch element.
  # @originalTarget: the shape that was deleted that started this 
  #                  deletion chain.
  delete: (originalTarget = this) =>
    return if @_deleting == true

    # emit a beforeDelete event and check if deletion is prevented
    @_deleting = true
    @emit "beforeDelete", originalTarget: originalTarget
    return unless @_deleting

    # delete the sketch element
    @emit "delete"
    @removeEvent() # (removes all event listeners)

  # Prevents this sketch element from being deleted if it was in the process of
  # being deleted.
  preventDeletion: ->
    @_deleting = false