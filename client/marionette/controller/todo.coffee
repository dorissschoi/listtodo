_ = require 'underscore'
Backbone = require 'backbone'
Marionette = require 'backbone.marionette'
lib = require '../lib.coffee'
View = lib.View
ModelView = lib.ModelView
model = require '../../model.coffee'
Todo = model.Todo
vent = require '../../vent.coffee'

class TodoCreateView extends View
	template: (data) =>
		@form.render().el
			
	events:
		'submit form#todoCreate': 'create'
	
	onBeforeRender: ->
		@form = new Backbone.Form
			model: 		@model
			template: 	_.template """
					<form id='todoCreate' class="form-horizontal">
						 <div data-fieldsets>
						 </div>
						 <button type='submit' class='btn btn-default'>
						 	<span class="glyphicon glyphicon-floppy-disk"></span>
						 	Create
						 </button>
					</form>
				"""
			fields:		@model.fields()
		
	create: ->
		success = (model, response, options) =>
			@router.listView.once 'render', ->
				vent.trigger 'show:msg', 'Todo has been successfully created', 'success'
			@router.navigate 'todo/list', trigger: true
			
		error = (model, xhr, options) ->
			vent.trigger 'show:msg', "#{xhr.statusText} #{xhr.responseText}", 'error'
			
		valid = @form.commit()
		if _.isUndefined(valid)
			@form.model.save {}, {success: success, error: error}
		return false

class TodoReadView extends View
	template: (data) =>
		"""
			<a class='btn btn-default' href='#todo/update/#{@model.id}'>
				<span class="glyphicon glyphicon-edit"></span>
				Update
			</a>
			<a class='btn btn-default' href='#confirmDel' role='button' data-toggle="modal">
				<span class="glyphicon glyphicon-remove"></span>
				Delete
			</a>
			<div id='confirmDel' class="modal fade">
				<div class="modal-dialog">
  					<div class="modal-content">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal">&times;</button>
							<h4 class='modal-title'>Delete Todo</h4>
						</div>
						<div class="modal-body">
							<p>Confirm to delete?</p>
						</div>
						<div class="modal-footer">
							<button type='button' class="btn btn-default" data-dismiss='modal'>Cancel</button>
							<button type='button' id='todoDelete' class="btn btn-primary" data-dismiss='modal'>
								<span class="glyphicon glyphicon-remove"></span>
								Delete
							</button>
						</div>
					</div>
				</div>
			</div>
			<div class='data'>
			</div>
		"""
	
	modelEvents:
		'change':	'render'	
	
	events:
		'click button#todoDelete': 'remove'
		
	onRender: ->
		view = new lib.ModelView {el: 'div.data', model: @model}
		view.render()
		
		
	remove: -> 
		success = (model, response, options) =>
			@router.listView.once 'render', ->
				vent.trigger 'show:msg', 'Todo has been successfully deleted', 'success'
			@router.navigate 'todo/list', trigger: true
			
		error = (model, xhr, options) ->
			vent.trigger 'show:msg', "#{xhr.statusText} #{xhr.responseText}", 'error'
			
		@$el.find("#confirmDel.modal").modal('hide').on 'hidden.bs.modal', =>
			@model.destroy {success: success, error: error}		
		
class TodoUpdateView extends View
	template: (data) =>
		@form.render().el
			
	events:
		'submit form#todoUpdate': 'update'

	modelEvents:
		'change':	'render'
				
	onBeforeRender: ->
		@form = new Backbone.Form
			model: 		@model
			template: 	_.template """
					<form id='todoUpdate' class="form-horizontal">
						 <div data-fieldsets>
						 </div>
						 <button type='submit' class='btn btn-default'>
						 	<span class="glyphicon glyphicon-edit"></span>
						 	Update
						 </button>
					</form>
				"""
			fields:	@model.fields()
			
	update: ->
		success = (model, response, options) =>
			@router.listView.once 'render', ->
				vent.trigger 'show:msg', 'Todo has been successfully updated', 'success'
			@router.navigate 'todo/list', trigger: true
			
		error = (model, xhr, options) ->
			vent.trigger 'show:msg', "#{xhr.statusText} #{xhr.responseText}", 'error'
			
		valid = @form.commit()
		if _.isUndefined(valid)
			@form.model.save {}, {success: success, error: error}
		return false
		
class TodoListView extends View
	template: (data) =>
		container = """
			<div>
				<div class="left-inner-addon form-inline search">
					<i class="glyphicon glyphicon-search"></i>
					<input class="form-control" id="search" type="text">
				</div>
				<a href='#todo/create' class='btn btn-default pull-right'>
					<span class="glyphicon glyphicon-plus"></span>
					Create
				</a>
			</div>
			<ul class='data-list'><%= obj.liNodes %></ul>
		"""
		element = "<li><a href='#todo/read/<%= obj.id %>'><%= obj.toString() %></a></li>"
		liNodes = ''
		@collection.each (todo, key, list) ->
			liNodes += _.template element, todo			
		return _.template container, {liNodes: liNodes}

class TodoSearchView extends View
	searchTag: =>
		container = """
			<div class="left-inner-addon form-inline search">
				<i class="glyphicon glyphicon-search"></i>
				<input class="form-control todo-search" type="text">
			</div>
			<div id='result'><%=obj.result%></div>
		"""
		
	resultTag: =>
		container = """
			<ul class='todo-list'>
				<%=obj.liNodes%>			</ul>
			<ul class="todo-pager pager">
				<li class="previous <%=obj.collection.hasPrevious() ? '' : 'disabled'%>">
					<a href="#">&laquo; prev</a>
				</li>
				<li class="next <%=obj.collection.hasNext() ? '' : 'disabled'%>">
					<a href="#">next &raquo;</a>
				</li>
			</ul>
		"""
		element = """
			<li id='<%=obj.get('_id')%>'>
				<%=obj.toString()%>			</li>
		"""
		liNodes = ''
		@collection.each (item, key, list) ->
			liNodes += _.template element, item			
		return _.template container, {collection: @collection, liNodes: liNodes}
		
	template: (data) =>
		_.template @searchTag(), result: @resultTag()
		
	events:
		'input .todo-search':				'search'
		'click .todo-list li':				'select'
		'click .todo-pager li.previous':	'prev'
		'click .todo-pager li.next':		'next'
		
	collectionEvents:
		'add':				'refresh'
		'change':			'refresh'
		'remove':			'refresh'
		'reset':			'refresh'

	refresh: ->
		@$el.find('div#result').html @resultTag()
		
	search: (event) ->
		@collection.search $(event.target).val()
		
	select: (event) ->
		@router.navigate "#todo/read/#{$(event.target).attr('id')}", trigger: true
		
	prev: (event) ->
		if $(event.currentTarget).hasClass('disabled')
			return false
		@collection.getPreviousPage()
		return false
		
	next: (event) ->
		if $(event.currentTarget).hasClass('disabled')
			return false
		@collection.getNextPage()
		return false

module.exports =	
	TodoListView: 	TodoListView
	TodoCreateView: TodoCreateView
	TodoReadView: 	TodoReadView
	TodoUpdateView: TodoUpdateView
	TodoSearchView: TodoSearchView