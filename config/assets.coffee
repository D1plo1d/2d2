# Asset rack configuration

# A list of directories, in order, which will be recursively parsed for css, javascript, and templates
# and then can be automatically injected in your layout/views via the view partials:
# ( assets.css(), assets.js() and assets.templateLibrary() )
module.exports.assets = sequence: [
  "assets/mixins",
  "assets/js",
  "assets/styles",
  "assets/templates"
]
