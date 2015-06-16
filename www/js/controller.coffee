env = require './env.coffee'

AppCtrl = ($rootScope, $scope, $http, platform, authService, model) ->	
	# set authorization header once mobile authentication completed
	fulfill = (data) ->
		if data?
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
	
	$scope.$on 'event:auth-forbidden', ->
		platform.auth().then fulfill, alert
	$scope.$on 'event:auth-loginRequired', ->
		platform.auth().then fulfill, alert
	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator
					
					
FileCtrl = ($rootScope, $scope, $stateParams, $location, $ionicModal, model) ->
	class FileView
	
		events:
			'change:folder':	'cd'
			'new:folder':		'md'
		
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@model = opts.model
			
		home: ->
			$location.url("file/todo/")
		
		cd: (folder = null) ->
			if _.isEmpty folder or _.isNull folder or _.isUndefined folder
				model.User.me()
					.then (user) =>
						@model.path = "#{user.username}/"
						@loadMore()
					.catch alert
			else
				@model.path = folder
				@loadMore()
			
		md: (folder = 'New Folder/') ->
			folder = new model.File path: "#{@model.path}#{folder}"
			folder.$save()
				.then =>
					@model.add folder
				.catch alert
				
		# read next page of files under current path
		loadMore: ->
			@model.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
			return @
		
		# update properties of specified file
		edit: ->
			$ionicModal.fromTemplateUrl('templates/file/edit.html', scope: $scope).then (modal) =>
				$scope.model.newname = $scope.model.name
				$scope.modal = modal
				$scope.modal.show()
				
		remove: (file) ->
			@model.remove(file)
			
		upload: (files) ->
			_.each files, (local) =>
				remote = (_.findWhere @model.models, name: local.name) || new model.File path: "#{@model.path}#{local.name}"
				remote.$save {file: local}
					.then =>
						@model.add remote
					.catch alert

	if _.isUndefined $scope.model
		$scope.model = new model.File path: $stateParams.path
		$scope.model.$fetch()
	$scope.controller = new FileView(model: $scope.model)
		
	$scope.$watchCollection 'files', (newfiles, oldfiles) ->
		if newfiles?.length? and newfiles?.length != oldfiles?length
			$scope.controller.upload newfiles
		
	$scope.$watchCollection 'model.tags', (newtags, oldtags) ->
		if newtags?.length != oldtags?.length
			$scope.model.$save().catch alert
			
	###
	$scope.$watch 'model.path', (newpath, oldpath) ->
		if newpath != oldpath
			$scope.controller.cd(newpath)
	###

SelectCtrl = ($scope, $ionicModal) ->
	class SelectView
		select: (@name, @model, @collection) ->
			$ionicModal.fromTemplateUrl('templates/permission/select.html', scope: $scope).then (modal) =>
				@modal = modal
				@modal.show()
				
		ok: ->
			$scope.$emit @name, @model 
			@modal.remove()
			
		cancel: ->
			_.extend @model, @model.previousAttributes
			@modal.remove()
			
	$scope.controller = new SelectView()
	
MultiSelectCtrl = ($scope, $ionicModal) ->
	class MultiSelectView
		# model: array of selected values
		select: (@name, @model, @collection) ->
			$ionicModal.fromTemplateUrl('templates/permission/multiselect.html', scope: $scope).then (modal) =>
				@modal = modal
				@modal.show()
		
		selected: (value) ->
			_.contains @model, value
			
		ok: ->
			@model = _.map $(@modal.$el).find('input:checked'), (el) ->
				el.name
			$scope.$emit @name, @model
			@modal.remove()
			
		cancel: ->
			_.extend @model, @model.previousAttributes
			@modal.remove()
			
	$scope.controller = new MultiSelectView()
	
PermissionCtrl = ($rootScope, $scope, $ionicModal, model) ->
	class PermissionView
		modelEvents:
			userGrp:	'update'
			fileGrp:	'update'
			action:		'update'
		
		constructor: (opts = {}) ->
			@model = opts.model
			
			_.each @modelEvents, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: (event, value) =>
			@model[event.name] = value
			
		save: ->
			@model.$save().catch alert
										
	$scope.controller = new PermissionView model: $scope.model
		
AclCtrl = ($rootScope, $scope, model) ->
	class AclView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
			$scope.userGrps = new model.UserGrps()
			$scope.userGrps.$fetch()
			
			$scope.fileGrps = new model.FileGrps()
			$scope.fileGrps.$fetch()
			
			$scope.actions = new model.Collection(['read', 'write'])
				
		loadMore: ->
			@collection.$fetch()
				.then ->
					$scope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert
				
		add: ->
			@collection.add new model.Permission
				userGrp:	''
				fileGrp:	''
				action:		[]
				
		remove: (perm) ->
			@collection.remove perm
	
	$scope.collection = new model.Acl()
	$scope.collection.$fetch()
	$scope.controller = new AclView collection: $scope.collection 


TodoCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->
	class TodoView  			

		constructor: (opts = {}) ->
			$scope.todo = {task: '', timeStart: new Date(), timeEnd: new Date(), dateStart: new Date(), dateEnd: new Date()}
			
			# datepicker config
			$scope.datepickers = 
				dateEnd: false
				dateStart: false
      
			$scope.minDate = $scope.minDate ? null : new Date()	
			$scope.maxDate = $scope.maxDate ? null : new Date(new Date().setYear(new Date().getFullYear() + 3))
			$scope.format = 'dd-MMMM-yyyy'	
			$scope.dateOptions =
				formatYear: 'yy'
				startingDay: 1
			
			# timepicker config
			$scope.hstep = 1
			$scope.mstep = 1

			$scope.options = 
				hstep: [1, 2, 3]
				mstep: [1, 5, 10, 15, 25, 30]

			$scope.ismeridian = true

		add: ->
			@model = new model.Todo
			@model.task = $scope.todo.task
			
			@model.dateStart = $scope.todo.dateStart
			@model.dateEnd = $scope.todo.dateEnd
			@model.timeStart = $scope.todo.timeStart
			@model.timeEnd = $scope.todo.timeEnd
			
			@model.$save().catch alert
			$scope.todo.task = ''	
			$state.go 'app.todo'
			
		read: (id) ->
			@model = new model.Todo 
			@model.id = id
			@model.$fetch()
			
		open: ($event, which) ->
			$event.preventDefault()
			$event.stopPropagation()
			$scope.datepickers[which]= true;
						
	$scope.controller = new TodoView model: $scope.models

TodoListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->
	class TodoListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
			@collection = opts.collection
			
			# datepicker config
			$scope.datepickers = 
				dateEnd: false
				dateStart: false
      
			$scope.format = 'dd-MMMM-yyyy'	
			$scope.dateOptions =
				formatYear: 'yy'
				startingDay: 1
			
			# timepicker config
			$scope.hstep = 1
			$scope.mstep = 1

			$scope.options = 
				hstep: [1, 2, 3]
				mstep: [1, 5, 10, 15, 25, 30]

			$scope.ismeridian = true
						
		#loadMore: ->
		#	@collection.$fetch()
		#		.then ->
		#			$rootScope.$broadcast('scroll.infiniteScrollComplete')
		#		.catch alert				
	
		# refresh new add task
		$rootScope.$on 'todo:listChanged', ->
			$scope.collection = new model.TodoList()
			$scope.collection.$fetch()
			$scope.controller = new TodoListView collection: $scope.collection

		remove: (todo) ->
			@model.remove(todo)			  
		
		# update properties of specified file
		edit: (selectedItem) ->
			$ionicModal.fromTemplateUrl('templates/todo/edit.html', scope: $scope).then (modal) =>
				$scope.model = selectedItem
				$scope.model.newtask = selectedItem.task
				$scope.model.newdateStart = selectedItem.dateStart
				$scope.model.newdateEnd = selectedItem.dateEnd
				$scope.model.newtimeStart = selectedItem.dateStart
				$scope.model.newtimeEnd = selectedItem.dateEnd				
				$scope.modal = modal
				$scope.modal.show()

		# open datepicker
		open: ($event, which) ->
			$event.preventDefault()
			$event.stopPropagation()
			$scope.datepickers[which]= true
			
		# edit page to list page
		refresh: ->
			$state.go 'app.todo', null, { reload: true }
			
				
	$scope.collection = new model.TodoList()
	$scope.collection.$fetch()
	$scope.controller = new TodoListView collection: $scope.collection

TodosFilter = ->
	(todos, search) ->
	 	return _.filter todos, (todo) ->
	 		if _.isUndefined(search)
	 			true
	 		else	
	 			todo.task.indexOf(search) > -1 
	
config = ->
	return
	
angular.module('starter.controller', ['ionic', 'ngCordova', 'http-auth-interceptor', 'starter.model', 'platform']).config [config]	
angular.module('starter.controller').controller 'AppCtrl', ['$rootScope', '$scope', '$http', 'platform', 'authService', 'model', AppCtrl]
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]
angular.module('starter.controller').controller 'FileCtrl', ['$rootScope', '$scope', '$stateParams', '$location', '$ionicModal', 'model', FileCtrl]
angular.module('starter.controller').controller 'PermissionCtrl', ['$rootScope', '$scope', '$ionicModal', 'model', PermissionCtrl]
angular.module('starter.controller').controller 'AclCtrl', ['$rootScope', '$scope', 'model', AclCtrl]
angular.module('starter.controller').controller 'SelectCtrl', ['$scope', '$ionicModal', SelectCtrl]
angular.module('starter.controller').controller 'MultiSelectCtrl', ['$scope', '$ionicModal', MultiSelectCtrl]
angular.module('starter.controller').controller 'TodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', TodoCtrl]
angular.module('starter.controller').controller 'TodoListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', TodoListCtrl]

angular.module('starter.controller').filter 'todosFilter', TodosFilter