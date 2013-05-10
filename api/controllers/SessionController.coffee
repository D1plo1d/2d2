# SessionController 

forms = require 'forms'
passport = require 'passport'
fields = forms.fields
validators = forms.validators

signInForm = forms.create
  username: fields.string required: true
  password: fields.password required: true

renderForm = (res, form = signInForm, flash = {}) ->
  res.view "sessions/new", fields: form.toHTML(), flash: flash


module.exports =

  new: (req, res) ->
    renderForm(res)

  create: (req, res, next) ->
    form = null
    auth = passport.authenticate 'local', (err, user, info) ->
      return next(err) if err
      unless user
        flash = {error: info.message}
        return renderForm res, form, flash
      req.logIn user, (err) ->
        if err then next(err) else res.redirect('/')

    signInForm.handle req,
      success: (f) ->
        # there is a request and the form is valid
        # form.data contains the submitted data
        form = f
        auth req, res, next
      error: (f) ->
        # the data in the request didn't validate,
        # calling form.toHTML() again will render the error messages
        renderForm res, f
      empty: (f) ->
        # there was no form data in the request
        renderForm res, f

  destroy: (req, res) ->
    res.view()
