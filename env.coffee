envClient = require './client/env.coffee'

env =
	log4js: 	require 'log4js'
	oauth2:
		verifyURL:			"#{envClient.authUrl}/oauth2/verify/"
	role:
		all:	'All Users'
	path:		envClient.path
	
	dburl:	'mongodb://todorw:pass1234@localhost/todo'
					
module.exports = env