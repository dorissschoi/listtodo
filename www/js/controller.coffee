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

TodoReadCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model, $filter) ->
	class TodoReadView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@model = opts.model
			$scope.model = $stateParams.SelectedTodo
			$scope.model.newtask = $scope.model.task
			
			# ionic-datepicker
			$scope.slots = [{epochTime: 0, format: 12, step: 15},{epochTime: 0, format: 12, step: 15}]
			newdate = new Date($filter('date')($scope.model.dateStart, 'MMM dd yyyy UTC'))
			$scope.model.newdateStart = newdate
			newdate = new Date($filter('date')($scope.model.dateEnd, 'MMM dd yyyy UTC'))
			$scope.model.newdateEnd = newdate
			$scope.model.newtimeStart = $scope.model.dateStart.getHours()*60*60 + $scope.model.dateStart.getMinutes()*60
			$scope.model.newtimeEnd = $scope.model.dateEnd.getHours()*60*60 + $scope.model.dateEnd.getMinutes()*60
			$scope.newdateStartPickerCallback = (val) ->
				if typeof val != 'undefined'
					$scope.model.newdateStart = val	
				return	
			$scope.newdateEndPickerCallback = (val) ->
				if typeof val != 'undefined'
					$scope.model.newdateEnd = val
				return	

			# ionic-timepicker
			$scope.slots = [{epochTime: 0, format: 12, step: 15},{epochTime: 0, format: 12, step: 15}]
			$scope.newtimeStartPickerCallback = (val) ->
				if typeof val != 'undefined'
					$scope.model.newtimeStart = val
				return	
			$scope.newtimeEndPickerCallback = (val) ->
				if typeof val != 'undefined'
					$scope.model.newtimeEnd = val
				return			

		# edit page to list page
		refresh: ->
			$state.go 'app.mytodo', null, { reload: true }
			
	$scope.controller = new TodoReadView model: $scope.model

	
TodoCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model, $filter) ->
	class TodoView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@model = opts.model
			$scope.todo = {task: ''}
				
		add: ->
			@model = new model.Todo
			@model.task = $scope.todo.task
			output = new Date($scope.startDate.getFullYear(),$scope.startDate.getMonth(), $scope.startDate.getDate(), parseInt($scope.startTime / 3600), $scope.startTime / 60 % 60)
			@model.dateStart = output
			output = new Date($scope.endDate.getFullYear(),  $scope.endDate.getMonth(),   $scope.endDate.getDate(), parseInt($scope.endTime / 3600), $scope.endTime / 60 % 60)
			@model.dateEnd = output
			@model.$save().catch alert
			$scope.todo.task = ''	
			$state.go 'app.mytodo'
		
		itemClick: (selectedModel) ->
			$state.go('app.readTodo', {'model': selectedModel})
						
	$scope.controller = new TodoView model: $scope.model
	
	# ionic-datepicker
	currDate = new Date	
	$scope.startDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
	$scope.endDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
	$scope.startTime = 12600
	$scope.endTime = 12600	
	$scope.dateStartPickerCallback = (val) ->
		if typeof val == 'undefined'
			$scope.startDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.startDate = val	
		return	
	$scope.dateEndPickerCallback = (val) ->
		if typeof val == 'undefined'
			$scope.endDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else 	
			$scope.endDate = val
		return	

	# ionic-timepicker
	$scope.slots = [{epochTime: 0, format: 12, step: 15},{epochTime: 0, format: 12, step: 15}]
	$scope.timeStartPickerCallback = (val) ->
		if typeof val == 'undefined'
			$scope.startTime = 12600
		else 	
			$scope.startTime = val
		return	
	$scope.timeEndPickerCallback = (val) ->
		if typeof val == 'undefined'
			$scope.endTime = 12600
		else 	
			$scope.endTime = val
		return	
	$scope.controllername = 'TodoCtrl'

TodoListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, model) ->
	class TodoListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection
			
		loadMore: ->
			@collection.$fetch()
				.then ->
					$rootScope.$broadcast('scroll.infiniteScrollComplete')
				.catch alert				
	
		# refresh new add task
		$rootScope.$on 'todo:mylistChanged', ->
			$scope.collection = new model.TodoList()
			$scope.collection.$fetch().then =>
				$scope.controller = new TodoListView collection: $scope.collection
			$ionicHistory.nextViewOptions({historyRoot: true})
			$ionicHistory.clearCache()

		remove: (todo) ->
			@model.remove(todo)			  
		
		
	if _.isUndefined $scope.collection				
		$scope.collection = new model.TodoList()
		$scope.collection.$fetch()
	$scope.controller = new TodoListView collection: $scope.collection


TodoCalCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->
	class TodoCalView
		constructor: (opts = {}) ->
			@collection = opts.collection
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
		
	$scope.collection = new model.TodoListCol()
	$scope.collection.$fetch().then ->
	
		$scope.eventsafter = 1			
		$scope.events.push({title: 'After event', type: 'info', draggable: true, resizable: true, startsAt: new Date(2015,6,1,15)  , endsAt: new Date(2015,6,2,15) })
		_.each $scope.collection.models, (todo) =>
			newtodo = _.pick todo, 'title', 'type', 'startsAt', 'endsAt', 'resizable', 'draggable'
			$scope.events.push(newtodo)
		$scope.eventsafter = 2
	$scope.controller = new TodoCalView collection: $scope.collection
						
	#Start Angular Calendar
	#These variables MUST be set as a minimum for the calendar to work
	$scope.calendarView = 'month'
	$scope.calendarDay = new Date()
	$scope.events = [
		{
			title: 'ABC'
			type: 'info'
			startsAt: new Date(2015,6,1,15) 
			endsAt: new Date(2015,6,1,18)
			draggable: true
			resizable: true
		}
	]				
			
	$scope.eventClicked = (event) ->
		showModal 'Clicked', event
	$scope.eventEdited = (event) ->
		showModal 'Edited', event
	$scope.eventDeleted = (event) ->
		showModal 'eventDeleted', event	
	$scope.eventTimesChanged = (event) ->
		showModal 'eventTimesChanged', event	 
	$scope.toggle = ($event, field, event) ->
		$event.preventDefault()
		$event.stopPropagation()
		event[field] = !event[field]  
	showModal = (action, event) ->
		$modal.open
			templateUrl: 'modalContent.html'
			controller: ->
				$scope.action = action
				$scope.event = event
				controllerAs: 'vm'			 	  
	#End Angular Calendar	
		 

MyTodoListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, model) ->
	class MyTodoListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@model.remove(todo)
	
		# refresh new add task
		$rootScope.$on 'todo:mylistChanged', ->
			$scope.collection = new model.MyTodoList()
			$scope.collection.$fetch().then =>
				$scope.controller = new MyTodoListView collection: $scope.collection
			$ionicHistory.nextViewOptions({historyRoot: true})
			$ionicHistory.clearCache()			
						
	$scope.collection = new model.MyTodoList()
	$scope.collection.$fetch()
	$scope.controller = new MyTodoListView collection: $scope.collection
								
TodosFilter = ->
	(todos, search) ->
	 	return _.filter todos, (todo) ->
	 		if _.isUndefined(search)
	 			true
	 		else if _.isEmpty(search)
	 			true
	 		else	
	 			todo.task.indexOf(search) > -1 

# ionic-timepicker plugin directive
standardTimeMeridian  = ->

	restrict: 'AE'
	replace: true
	scope: etime: '=etime'
	template: '<strong>{{stime}}</strong>'
	link: (scope, elem, attrs) ->
	
		prependZero = (param) ->
			if String(param).length < 2
				return '0' + String(param)
			param
	
		epochParser = (val, opType) ->
			if val == null
				return '00:00'
			else
				meridian = [
					'AM'
					'PM'
				]
			if opType == 'time'
				hours = parseInt(val / 3600)
				minutes = val / 60 % 60
				hoursRes = if hours > 12 then hours - 12 else hours
				currentMeridian = meridian[parseInt(hours / 12)]
				return prependZero(hoursRes) + ':' + prependZero(minutes) + ' ' + currentMeridian
			return
	
		scope.stime = epochParser(scope.etime, 'time')
		scope.$watch 'etime', (newValue, oldValue) ->
			scope.stime = epochParser(scope.etime, 'time')
			return
		return

	
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

angular.module('starter.controller').controller 'TodoReadCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', '$filter', TodoReadCtrl]
angular.module('starter.controller').controller 'TodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', '$filter', TodoCtrl]

angular.module('starter.controller').controller 'TodoListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', 'model', TodoListCtrl]
angular.module('starter.controller').controller 'TodoCalCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', TodoCalCtrl]
angular.module('starter.controller').controller 'MyTodoListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', 'model', MyTodoListCtrl]

angular.module('starter.controller').filter 'todosFilter', TodosFilter

angular.module('starter.controller').directive 'standardTimeMeridian', standardTimeMeridian 
