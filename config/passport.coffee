passport = require("passport")
LocalStrategy = require("passport-local").Strategy

validatePassword = (user, password) ->
  user.cryptedPassword == password

passport.use new LocalStrategy (username, password, done) ->
  console.log username
  User.find(username: username).done (err, user) ->
    return done(err) if err
    unless user?
      return done null, false, message: "Incorrect username."
    unless validatePassword(user, password)
      return done null, false, message: "Incorrect password."
    done null, user
