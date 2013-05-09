# passport = require("passport")
# LocalStrategy = require("passport-local").Strategy

# passport.use new LocalStrategy (username, password, done) ->
#   User.findOne
#     username: username, (err, user) ->
#       return done(err)  if err
#       unless user
#         return done(null, false,
#           message: "Incorrect username."
#         )
#       unless user.validPassword(password)
#         return done(null, false,
#           message: "Incorrect password."
#         )
#       done null, user
