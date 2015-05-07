Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
vent = require '../vent.coffee'

class View extends Marionette.ItemView
	constructor: (opts) ->
		@router = opts.router
		super(opts)
		
	render: ->
		FlashView.getInstance().render()
		super()
		
class FlashView extends Marionette.ItemView
	@nil = new Backbone.Model {msg: '', type: 'nil'} 
	
	template: (data) =>
		switch data.type
			when 'success'
				"""
					<div class="alert bg-success">
  						<button type="button" class="close" data-dismiss="alert">&times;</button>
  						<h4>Success!</h4>#{data.msg}
					</div>
				"""
			when 'info'
				"""
					<div class="alert bg-info">
  						<button type="button" class="close" data-dismiss="alert">&times;</button>
  						<h4>Information!</h4>#{data.msg}
					</div>
				"""
			when 'warn'
				"""
					<div class="alert bg-warn">
  						<button type="button" class="close" data-dismiss="alert">&times;</button>
  						<h4>Warning!</h4>#{data.msg}
					</div>
				"""
			when 'error'
				"""
					<div class="alert bg-danger">
  						<button type="button" class="close" data-dismiss="alert">&times;</button>
  						<h4>Error!</h4>#{data.msg}
					</div>
				"""
			when 'nil'
				""
			else
				"""
					<div class="alert">
  						<button type="button" class="close" data-dismiss="alert">&times;</button>
  						#{data.msg}
					</div>
				"""
			
	constructor: (opts = {}) ->
		if not ('model' of opts)
			opts.model = FlashView.nil
		super(opts)
		# type: success, info, error, other
		vent.on 'show:msg', (msg, type='other') =>
			@model = new Backbone.Model({type: type, msg: msg})
			@render()
			
	render: ->
		super
		@model = FlashView.nil
		
	@getInstance: ->
		@_instance ?= new FlashView(el: $('div#flash'))
		
class ModelView extends Marionette.ItemView
	template: (data) =>
		"<div class='model'>#{ModelView.show(@model)}</div>"

	@show: (obj) ->
		if _.isNaN(obj) or _.isNull(obj) or _.isUndefined(obj)
			return ''
			
		ret = ''
		
		if typeof obj == 'object'
		
			if obj instanceof Backbone.Collection			# Collection
				obj.each (value, key, list) ->
					ret += """
						<div class='field'>
							#{ModelView.show value}
						</div>
					""" 
				
			else if obj instanceof Backbone.Model			# Model
				view = obj.pick obj.showFields()			# show attributes only if defined in model.showFields()
				_.each view, (value, key, list) ->
					ret += """
						<div class='field'>
							<label class='key'>#{obj.schema[key].title}</label>
							#{ModelView.show value}
						</div>
					"""
					
			else if _.isArray obj
				_.each obj, (value) ->
					ret += """
						<div class='field'>
							#{ModelView.show value}
						</div>
					""" 
					
			else if _.isDate obj
				ret += obj.toLocaleString()
									
			else	 										# Plain Object
				_.each obj, (value, key, list) ->
					ret += """
						<div class='field'>
							<label class='key'>#{key}</label>
							#{ModelView.show value}
						</div>
					"""
			
		else												# Primitive Type
			ret += "<span class='value'>#{obj}</span>"
		
		return ret
		
module.exports =
	View:		View
	FlashView:	FlashView
	ModelView:	ModelView