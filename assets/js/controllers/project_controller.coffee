# This will eventually be the place that we put multiple sketches.
# It will also have a project "model" in the kernel.
class @ProjectController

  constructor: (@project) ->
    console.log "wut"
    $(document).on("keydown", "ctrl+n", @newSketch)
    # @project.on "add", @_onAddSketch
    @newSketch()

  newSketch: (e) =>
    @currentSketchController?.stop()
    sketch = new kernel.Sketch()
    @currentSketchController = new SketchController sketch
    @project.add sketch
    e?.stopPropagation( )  
    e?.preventDefault( )
    return false

  # _onAddSketch: (sketch) =>
  # This would add a sketch controller to each sketch if it does not already have one
