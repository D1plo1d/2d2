class @LineController extends @ShapeController
  numberOfPoints: 2
  raphaelType: "path"


  _create: (ui) ->
    @_addNthPoint(@points.length) if ui == true


  # create the first point and then display the line while positioning the second
  _addNthPoint: (n) -> switch n
    when 0, 1
      @_addPoint().$node.one "aftercreate", => @_addNthPoint(@points.length)
      if n == 1 then @_initElement()
    when 2 # there is no point with index 2, finish the line creation
      @_afterCreate()


  _attrs: ->
    path: "M#{@points[0].x()}, #{@points[0].y()}L#{@points[1].x()},#{@points[1].y()}"


  _dragElement: (e, mouseVector) ->
    console.log "dragging"


  _afterCreate: =>
    # TODO: move this to shape or line?
    @shift = false
    $(document).bind "keydown", "shift", => @shift = true
    $(document).bind "keyup", "shift", => @shift = false

    $(@$svg).bind "aftercreate", (e) =>
      if @shift and e.shape.shapeType == "line"
        @line(points: [ e.shape.points[1] ])
