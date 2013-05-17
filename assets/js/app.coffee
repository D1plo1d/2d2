#= require "../../components/es5-shim/es5-shim.min.js"
#= require "../../components/json3/lib/json3.min.js"
#= require "../../components/jquery/jquery.min.js"
#= require "../../components/sugar/release/sugar-full.min.js"
#= require "../../components/bootstrap-stylus/js/bootstrap-tooltip.js"
#= require "../../components/bootstrap-stylus/js/bootstrap-popover.js"

# Angular JS
#= require "../../components/angular/angular.js"
#= require "../../components/angular-resource/angular-resource.js"
#= require "../../components/angular-sanitize/angular-sanitize.js"

# SVG Sketch Dependencies
#= require "../../components/jquery-mousewheel/jquery.mousewheel.js"
#= require "../../components/jquery-hotkeys/jquery.hotkeys.js"
#= require "../../components/svg.js/dist/svg.js"
#= require "../../components/hammerjs/dist/hammer.min.js"
#= require "../../components/hammerjs/dist/jquery.hammer.min.js"

# Constraint Solver Dependencies
#= require "../../components/eventEmitter/EventEmitter.js"

# Custom Libs
#= require "svg.interactive"
#= require "svg.yan_draggable"

# The CAD Kernel
#= require "kernel/kernel"
#= require "kernel/sketch"
#= require "kernel/sketch_element"
#= require "kernel/point"
#= require "kernel/shape"
#= require "kernel/project"

# The Controllers
#= require "controllers/sketch_controller"
#= require "controllers/shape_controller"
#= require "controllers/point_controller"
#= require "controllers/project_controller"
#= require_tree "controllers/shapes"

# The App
project = new kernel.Project()
new ProjectController(project)

