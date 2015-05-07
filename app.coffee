env = require './env.coffee'
envClient = require './client/env.coffee'
logger = env.log4js.getLogger('app.coffee')
model = require './model'
i18n = require 'i18n'
passport = require 'passport'
bearer = require 'passport-http-bearer'
http = require 'needle'
_ = require 'underscore'
fs = require 'fs'
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

dir = '/etc/ssl/certs'
files = fs.readdirSync(dir).filter (file) -> /.*\.pem/i.test(file)
files = files.map (file) -> "#{dir}/#{file}"
ca = files.map (file) -> fs.readFileSync file

i18n.configure
	locales:		['en', 'zh', 'zh-tw']
	directory:		__dirname + '/locales'
	defaultlocale:	'en'

passport.serializeUser (user, done) ->
	done(null, user.id)
	
passport.deserializeUser (id, done) ->
	model.User.findById id, (err, user) ->
		done(err, user)

passport.use 'bearer', new bearer.Strategy {}, (token, done) ->
	opts = 
		ca:		ca
		headers:
			Authorization:	"Bearer #{token}"
	http.get env.oauth2.verifyURL, opts, (err, res, body) ->
		if err?
			logger.error err
				
		client_id = body.client_id
		
		# check required scope authorized or not
		scope = body.scope.split(' ')
		result = _.intersection scope, envClient.oauth2.scope
		if result.length != envClient.oauth2.scope.length
			return done('Unauthorzied access', null)
			
		# create user
		# otherwise check if user registered before (defined in model.User or not)
		user = _.pick body.user, 'url', 'username', 'email'
		model.User.findOrCreate user, (err, user) ->
			if err
				return done(err, null)
			done(err, user)
			
port = process.env.PORT || 3000

require('zappajs') port, ->
	@set 'view engine': 'jade'
	# strip url with prefix = env.path 
	@use (req, res, next) ->
		p = new RegExp('^' + env.path)
		req.url = req.url.replace(p, '')
		next()
	@use 'logger', 'cookieParser', session:{secret:'keyboard cat'}, 'bodyParser', 'methodOverride'
	@use passport.initialize()
	@use passport.session()
	@use static: __dirname + '/public'
	@use 'zappa'
	@use i18n.init
	# locales
	@use (req, res, next) ->
		if req.locale == 'zh' and req.region == 'tw'
			res.locals.setLocale 'zh-tw'
		next()
	
	@get '/', ->
		@render 'index.jade', {path: env.path, title: 'Todo'}
			
	@include './server/mongoose/url/todo.coffee'