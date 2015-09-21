env = require '../../../env.coffee'
lib = require '../lib.coffee'
mongoose = require 'mongoose'
model = require '../../../model.coffee'
_ = require 'underscore'

error = (res, msg) ->
	res.json 500, error: msg

class Todo

	@upcominglist: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		order_by = lib.order_by model.Todo.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Todo.ordering_fields() 
			order_by = lib.order_by req.query.order_by

		today = new Date()
		today = today.setHours(0,0,0,0)
		cond = { $and: [ { dateStart: { $gte: today } }, { createdBy: req.user } ] }
		
		model.Todo.find(cond, null, opts).populate('resource createdBy').sort(order_by).exec (err, todos) ->				
			if err
				return error res, err
			model.Todo.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: todos}

	@mylistpage: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		order_by = lib.order_by model.Todo.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Todo.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		cond = { createdBy: req.user } 				
		model.Todo.find(cond, null, opts).populate('resource createdBy').sort(order_by).exec (err, todos) ->
			if err
				return error res, err
			model.Todo.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: todos}


	@list: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit

		order_by = lib.order_by model.Todo.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Todo.ordering_fields() 
			order_by = lib.order_by req.query.order_by

		cond = { createdBy: req.user } 
		
		if req.query.fmDate and req.query.toDate
			date1 = new Date(req.query.fmDate)
			date2 = new Date(req.query.toDate)
			p1 = new lib.Period(date1, date2)
			cond = _.extend cond, p1.intersect("dateStart", "dateEnd")
			
		model.Todo.find(cond).populate('resource createdBy').sort(order_by).exec (err, todos) ->				
			if err
				return error res, err
			model.Todo.count {}, (err, count) ->
				if err
					return error res, err
				res.json {count: count, results: todos}
							
	@listold: (req, res) ->
		page = if req.query.page then req.query.page else 1
		limit = if req.query.per_page then req.query.per_page else env.pageSize
		opts = 
			skip:	(page - 1) * limit
			limit:	limit
			
		cond = {}
		if req.query.search 
			pattern = new RegExp(req.query.search, 'i')
			fields = _.map model.Todo.search_fields(), (field) ->
				ret = {}
				ret[field] = pattern
				return ret
			cond = $or: fields
			 
		if req.query.dtStart 
			date1 = new Date(req.query.dtStart)
			#cond1 = $gte: date1
			cond1 = dateStart : {$gte: date1}
			#cond1 = dateStart : {$gte: new Date("2015-06-14T00:00:00.000Z")}
			cond = cond1
					
		order_by = lib.order_by model.Todo.ordering()
		if req.query.order_by and lib.field(req.query.order_by) in model.Todo.ordering_fields() 
			order_by = lib.order_by req.query.order_by
		
		model.Todo.find(cond, null, opts).populate('createdBy updatedBy').sort(order_by).exec (err, todos) ->
			if err
				return error res, err
			model.Todo.count {}, (err, count) ->
				if err
					return error res, err
				if req.query.dtStart 	
					res.json {count: todos.length, results: todos}
				else	
					res.json {count: count, results: todos}
							
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

	@delete: (req, res) ->
		id = req.param('id')
		model.Todo.findOne {_id: id}, (err, todo) ->		
			if err or todo == null
				return error res, if err then err else "Todo not found"
			
			todo.remove (err, todo) ->
				if err
					error res, err
				else
					res.json {deleted: true}
								
module.exports = 
	Todo: 		Todo