controller = require "../controller/todo.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })

ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
middleware = require '../../../middleware.coffee'
ensurePermission = middleware.ensurePermission
 

bearer = middleware.rest.user
 
@include = ->

	@get '/api/mytodopage', bearer, ->
		controller.Todo.mylistpage(@request, @response)
	
	@get '/api/myupcomingtodo', bearer, ->
		controller.Todo.upcominglist(@request, @response)
		
	@post '/api/todo', bearer,  ->
		controller.Todo.create(@request, @response)
		 
	@put '/api/todo/:id', bearer,  ->
		controller.Todo.update(@request, @response)	

	@get '/api/todo', bearer, ->
		controller.Todo.list(@request, @response)
				
	@get '/api/todo/:id', bearer,   ->
		controller.Todo.read(@request, @response)
		
	@del '/api/todo/:id', bearer,  ->
		controller.Todo.delete(@request, @response)		