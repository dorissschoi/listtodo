env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class Todo


			
	@create: (req, res) ->
		data = req.body
		data.createdBy = req.user 
		todo = new model.Todo data
		todo.save (err) =>
			if err
				return error res, err
			res.json todo			
				
	@read: (req, res) ->
		id = req.param('id')
		model.Todo.findById(id).populate('createdBy updatedBy').exec (err, user) ->
			if err or todo == null
				return error res, if err then err else "Todo not found"
			res.json todo			
			
		
	@update: (req, res) ->
		id = req.param('id')
		model.Todo.findOne {_id: id, __v: req.body.__v}, (err, todo) ->
			if err or todo == null
				return error res, if err then err else "Todo not found"
			
			attrs = _.omit req.body, '_id', '__v', 'dateCrated', 'createdBy', 'lastUpdated', 'updatedBy'
			_.map attrs, (value, key) ->
				todo[key] = value
			todo.updatedBy = req.user
			todo.save (err) ->
				if err
					error res, err
				else res.json todo						

					
module.exports = 
	Todo: 		Todo