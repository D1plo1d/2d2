class kernel.Point extends kernel.SketchElement
  x: 0, y: 0
  placed: false

  _init: (opts) =>
    @emit "initialize"

  place: () ->
    placed = true
    @emit "place"

# Kernel.point.prototype.__iterator__ = ->
#   for val in [@x, @y] yield val
#   return
