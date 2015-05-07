controller = require "../controller/todo.coffee"
passport = require 'passport'
bearer = passport.authenticate('bearer', { session: false })
lib = require '../lib.coffee'
ensurePermission = lib.ensurePermission
 
@include = ->

	@get '/api/todo', bearer, ensurePermission('todo:list'), ->
		controller.Todo.list(@request, @response)
		
	@post '/api/todo', bearer, ensurePermission('todo:create'), ->
		controller.Todo.create(@request, @response) 
		
	@get '/api/todo/:id', bearer, ensurePermission('todo:read'), ->
		controller.Todo.read(@request, @response)
		
	@put '/api/todo/:id', bearer, ensurePermission('todo:update'), ->
		controller.Todo.update(@request, @response)
		
	@del '/api/todo/:id', bearer, ensurePermission('todo:delete'), ->
		controller.Todo.delete(@request, @response)