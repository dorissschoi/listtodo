Backbone = require 'backbone'

class Router extends Backbone.Router
	routes:
		'':			'index'
		
	index: ->
		@navigate 'todo/list', trigger: true
			
module.exports =
	Router: Router