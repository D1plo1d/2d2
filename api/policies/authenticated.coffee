###
Allow any authenticated user.
###
module.exports = (req, res, ok) ->
  throw "auth?"
  # User is allowed, proceed to controller
  if (req.isAuthenticated())
    ok()
  # User is not allowed. Prompt them to log in.
  else
    return res.redirect('/login')

  # # User is allowed, proceed to controller
  # if req.session.authenticated
  #   ok()
  
  # # User is not allowed
  # else
  #   res.send "You are not permitted to perform this action.", 403