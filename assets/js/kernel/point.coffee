class kernel.Point extends kernel.SketchElement
  x: 0, y: 0

  _init: (opts) =>
    @emit "initialize"

# Kernel.point.prototype.__iterator__ = ->
#   for val in [@x, @y] yield val
#   return
