# User Controller 

forms = require 'forms'
passport = require 'passport'
fields = forms.fields
validators = forms.validators

registrationForm = forms.create
  username: fields.string required: true
  password: fields.password required: true
  confirm:  fields.password
    required: true,
    validators: [validators.matchField('password')]
  email: fields.email()

module.exports = {}
