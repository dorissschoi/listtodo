env = require './env.coffee'
mongoose = require 'mongoose'
findOrCreate = require 'mongoose-findorcreate'
taggable = require 'mongoose-taggable'

mongoose.connect env.dburl

UserSchema = new mongoose.Schema
	url:			{ type: String, required: true, index: {unique: true} }
	username:		{ type: String, required: true }
	email:			{ type: String }
	
UserSchema.statics =
	search_fields: ->
		return ['username', 'email']
	ordering_fields: ->
		return ['username', 'email']
	ordering: ->
		return 'username'
	isUser: (oid) ->
		p = @findById(oid).exec()
		p1 = p.then (user) ->
			return user != null
		p1.then null, (err) ->
			return false		
		
UserSchema.plugin(findOrCreate)
UserSchema.plugin(taggable)

UserSchema.pre 'save', (next) ->
	@addTag(env.role.all)
	@increment()
	next()
	
User = mongoose.model 'User', UserSchema

TodoSchema = new mongoose.Schema
	task:			{ type: String }
	dateStart:		{ type: Date }
	dateEnd:		{ type: Date }			
	priority:		{ type: String }
	status:			{ type: String }
	createdBy:		{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }

TodoSchema.statics =
	search_fields: ->
		return ['dateStart', 'task']
	ordering_fields: ->
		return ['dateStart', 'task']
	ordering: ->
		return 'dateStart'	
		
TodoSchema.plugin(findOrCreate)
TodoSchema.plugin(taggable)

Todo = mongoose.model 'Todo', TodoSchema

module.exports = 
	User:		User
	Todo: 		Todo
	