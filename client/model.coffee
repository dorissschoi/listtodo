env = require './env.coffee'
Backbone = require 'backbone'
Model = Backbone.Model
PageableCollection = require 'backbone-pageable'

class User extends Model
	urlRoot:	"#{env.path}/api/user"
	
	schema:
		url:			{ type: 'Text', title: 'URL'}
		username:		{ type: 'Text', title: 'Username' }
		email:			{ type: 'Text', title: 'Email' }
		
class Users extends PageableCollection
	url:		"#{env.path}/api/user"
	
	comparator:	'username'
	
	model:	User
	
	schema:
		models:	{type: 'List', itemType: 'NestedModel', model: User }

class AllUsers extends Backbone.Collection
	url:		"#{env.path}/api/user/all"
	
	comparator:	'username'
	
	model:	User
	
	schema:
		models:	{type: 'List', itemType: 'NestedModel', model: User }
	
class OAuth2Users extends Users
	url:		env.user.url
		
	@me: ->
		user = new User()
		p = user.fetch url: env.user.url + 'me/'
		p.then ->
			return user
	
class Todo extends Backbone.Model
	idAttribute: "_id"
		
	schema:
		task:			{ type: 'Text', title: 'Task' }
		dateStart:		{ type: 'Date', title: 'Start date' }
		dateEnd:		{ type: 'Date', title: 'End date' }			
		priority:		{ type: 'Text', title: 'Priority' }
		status:			{ type: 'Text', title: 'Status' }
		tags:			{ type: 'List', itemType: 'Text', title: 'Tags'}

	fields:	->
		return [ 'task', 'dateStart', 'dateEnd', 'priority', 'status', 'tags' ]
		
	showFields: ->
		return [ 'task', 'dateStart', 'dateEnd', 'priority', 'status', 'tags' ]
	
	toString: ->
		return @get('task')	
							
class Todos extends Backbone.PageableCollection
	model:	Todo

	url:	"#{env.path}/api/todo"  

	comparator:	'task'
					
module.exports =
	User:			User
	Users:			Users
	AllUsers:		AllUsers
	OAuth2Users:	OAuth2Users
	Todo:			Todo
	Todos:		Todos
	