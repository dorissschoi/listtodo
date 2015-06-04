controller = require "../controller/todo.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })

ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
middleware = require '../../../middleware.coffee'
ensurePermission = middleware.ensurePermission
 

bearer = middleware.rest.user
 
@include = ->
		
	@post '/api/todo',  ->
		controller.Todo.create(@request, @response)
		 
	@put '/api/todo/:id',  ->
		controller.Todo.update(@request, @response)	

	@get '/api/todo',  ->
		controller.Todo.list(@request, @response)
				
	@get '/api/todo/:id',   ->
		controller.Todo.read(@request, @response)		