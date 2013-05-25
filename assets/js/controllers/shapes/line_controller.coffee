class @LineController extends @ShapeController
  numberOfPoints: 2
  svgType: "path"
  shapeType: "line"

  _create: (fullyDefined) ->
    @_addNthPoint(@kernelElement.points.length) unless fullyDefined

  # create the first point and then display the line while positioning the
  # second
  _addNthPoint: (n) => switch n
    when 0, 1
      super
      if n == 1 then @_initSvgElement()
    # when 2 # there is no point with index 2, finish the line creation
    #   @_afterCreate()

  _initSvgElement: ->
    @svgElement = @parent.groups.shapes[@svgType](@_path(), true).hide()

  _attrs: ->
    d: @_path()

  _path: ->
    p = @kernelElement.points
    "M#{p[0].x}, #{p[0].y}L#{p[1].x},#{p[1].y}"

  _onFullyDefine: =>
    console.log "fully defined!"
    console.log @parent.shift
    return unless @parent.shift
    @sketch.add new kernel.Shape
      type: "line"
      points: [@kernelElement.points[1]]
