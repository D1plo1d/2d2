class kernel.Project extends EventEmitter
  sketches: []

  add: (sketch) ->
    @sketches.push sketch
    @emit "add", sketch
