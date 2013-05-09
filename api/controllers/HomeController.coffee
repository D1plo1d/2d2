#---------------------
#	:: Home 
#	-> controller
#---------------------
HomeController =

  index: (req, res) ->
    res.view()

module.exports = HomeController