env = require './env.coffee'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'

class FlashView extends Marionette.ItemView
	className:	'alert'
	
	template: (data) =>
		header =
			success:	'Success!'
			info:		'Information!'
			warn:		'Warning!'
			error:		'Error!'
		if data.type?
			data.header = header[data.type]
		tmpl = """
			<button type="button" class="close" data-dismiss="alert">&times;</button>
			<h4><%= obj.header %></h4><%= obj.msg %>
		"""
		_.template tmpl, data
		
	constructor: (opts) ->
		type =
			success:	'bg-success'
			info:		'bg-info'
			warn:		'bg-warn'
			error:		'bg-danger'
		opts.className = "#{@className} #{type[opts.model.get('type')]}"
		super(opts)
		
	onRender: ->
		close = =>
			@$el.hide =>
				@remove()
		setTimeout close, env.flash.timeout

vent = new Backbone.Wreqr.EventAggregator()

vent.on 'show:msg', (msg, type='other') =>
	flash = new FlashView {model: new Backbone.Model({type: type, msg: msg})}
	flash.render().$el.prependTo('body')
			
module.exports = vent