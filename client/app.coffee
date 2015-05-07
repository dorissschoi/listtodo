env = require './env.coffee'
Backbone = require 'backbone'
require './form.coffee'
Marionette = require 'backbone.marionette'
router = require './router.coffee'
todo = require './marionette/url/todo.coffee'
model = require './model.coffee'
lib = require './marionette/lib.coffee'
vent = require './vent.coffee'

class App extends Marionette.Application
	constructor: (options) ->
		# configure to acquire bearer token for all api call from oauth2 server
		jso_configure 
			oauth2:
				client_id:		env.oauth2.clientID
				authorization:	env.oauth2.authorizationURL
				scope:			env.oauth2.scope

		sync = Backbone.sync
		Backbone.sync = (method, model, opts) ->
			error = opts.error
			opts.error = (resp) ->
				error(resp)
				vent.trigger 'show:msg', JSON.stringify(resp.responseJSON.error), 'error'
			sync method, model, opts
				
		Backbone.ajax = (settings) =>
			settings.jso_provider = 'oauth2'
			jso_ensureTokens oauth2: env.oauth2.scope
			Backbone.$.oajax(settings)
		
		success = (user) =>
			@router = new router.Router()
			@todo = new todo.Router()
			Backbone.history.start()
			
		error = ->
			alert 'Unauthorized access'
		
		model.OAuth2Users.me().then success, error
		
module.exports =
	App: App