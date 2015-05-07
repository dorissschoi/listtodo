proj = 'listtodo'
authServer = 'mppsrc.ogcio.hksarg'
authUrl = "https://#{authServer}/org"

env =
	authServer:	authServer
	authUrl:	authUrl

	user:
		url:	"https://#{authServer}/org/api/users/"
	path:		"/#{proj}"
	oauth2:
		authorizationURL:	"#{authUrl}/oauth2/authorize/"
		clientID:			"todo-dev"
		scope:				[ "https://#{authServer}/org/users", "https://#{authServer}/todo" ]
	flash:
		timeout:	5000		# ms
			
module.exports = env