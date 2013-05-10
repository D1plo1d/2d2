# ---------------------
#	:: Users
#	-> model
# ---------------------
module.exports =

	attributes:

    # Simple attribute:
    username: 'STRING'
    cryptedPassword: 'STRING'

    # Or for more flexibility:
    # phoneNumber: {
    # 	type: 'STRING',
    # 	defaultValue: '555-555-5555'
    #   filter: [bcrypt]
    #   getter: 
    #   setter: 
    # }

    # cryptedPassword: 
