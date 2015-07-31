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

TodoReadCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->
	class TodoReadView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@model = opts.model
			$scope.model = $stateParams.SelectedTodo
			$scope.model.newtask = $scope.model.task
			newdate = @changeFormat($scope.model.dateStart) 
			$scope.model.newdateStart = newdate
			newdate = @changeFormat($scope.model.dateEnd)
			$scope.model.newdateEnd = newdate
			$scope.model.newtimeStart = $scope.model.dateStart
			$scope.model.newtimeEnd = $scope.model.dateEnd	
			# datepicker config
			$scope.datepickers = 
				dateEnd: false
				dateStart: false
				      
			$scope.minDate = $scope.minDate ? null : new Date()	
			$scope.maxDate = $scope.maxDate ? null : new Date(new Date().setYear(new Date().getFullYear() + 3))
			$scope.format = 'dd/MM/yyyy'	
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
		
		changeFormat: (dateIn) ->
			dateMonth = dateIn.getMonth()+1
			if dateMonth < 10
				dateMonth = "0"+dateMonth
			
			dateDay = dateIn.getDate()
			if dateDay < 10
				dateDay = "0"+dateDay
			dateYear = dateIn.getFullYear()
			return dateDay+ "/" + dateMonth + "/"+ dateYear
											
		open: ($event, which) ->
			$event.preventDefault()
			$event.stopPropagation()
			$scope.datepickers[which]= true
		
		# edit page to list page
		refresh: ->
			$state.go 'app.mytodo', null, { reload: true }
			
	$scope.controller = new TodoReadView model: $scope.model

	
TodoCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model) ->
	class TodoView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@model = opts.model
			
			$scope.todo = {task: '', timeStart: new Date(), timeEnd: new Date(), dateStart: new Date(), dateEnd: new Date()}
			
			#change format at datepicker first show
			newdate = @changeFormat(new Date()) 
			$scope.todo.dateStart = newdate
			$scope.todo.dateEnd = newdate
			
			# datepicker config
			$scope.datepickers = 
				dateEnd: false
				dateStart: false
      
			$scope.minDate = $scope.minDate ? null : new Date()	
			$scope.maxDate = $scope.maxDate ? null : new Date(new Date().setYear(new Date().getFullYear() + 3))
			$scope.format = 'dd/MM/yyyy'	
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

		changeFormat: (dateIn) ->
			dateMonth = dateIn.getMonth()+1
			if dateMonth < 10
				dateMonth = "0"+dateMonth
			
			dateDay = dateIn.getDate()
			if dateDay < 10
				dateDay = "0"+dateDay
			dateYear = dateIn.getFullYear()
			return dateDay+ "/" + dateMonth + "/"+ dateYear			
			
		add: ->
			@model = new model.Todo
			@model.task = $scope.todo.task
			
			@model.dateStart = $scope.todo.dateStart
			@model.dateEnd = $scope.todo.dateEnd
			@model.timeStart = $scope.todo.timeStart
			@model.timeEnd = $scope.todo.timeEnd
			
			@model.$save().catch alert
			$scope.todo.task = ''	
			$state.go 'app.mytodo'

			
		# edit page to list page
		refresh: ->
			$state.go 'app.mytodo', null, { reload: true }
		
		itemClick: (selectedModel) ->
			$state.go('app.readTodo', {'model': selectedModel})
													
		read: (id) ->
			@model = new model.Todo 
			@model.id = id
			@model.$fetch()
			$scope.model = @model
			
		open: ($event, which) ->
			$event.preventDefault()
			$event.stopPropagation()
			$scope.datepickers[which]= true
						
	$scope.controller = new TodoView model: $scope.model
	$scope.minDate = $scope.minDate ? null : new Date()	
	$scope.maxDate = $scope.maxDate ? null : new Date(new Date().setYear(new Date().getFullYear() + 3))
	$scope.format = 'dd/MM/yyyy'	
	$scope.dateOptions =
		formatYear: 'yy'
		startingDay: 1	

TodoListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, $ionicViewSwitcher, model) ->
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
			$ionicViewSwitcher.nextDirection('back')  
			$ionicHistory.nextViewOptions({historyRoot: true})
			$ionicHistory.clearCache()


		remove: (todo) ->
			@model.remove(todo)			  
		
		# open datepicker
		open: ($event, which) ->
			$event.preventDefault()
			$event.stopPropagation()
			$scope.datepickers[which]= true

			

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
		 

MyTodoListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, $ionicViewSwitcher, model) ->
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
			$ionicViewSwitcher.nextDirection('back')  
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

angular.module('starter.controller').controller 'TodoReadCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', TodoReadCtrl]
angular.module('starter.controller').controller 'TodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', TodoCtrl]

angular.module('starter.controller').controller 'TodoListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', '$ionicViewSwitcher', 'model', TodoListCtrl]
angular.module('starter.controller').controller 'TodoCalCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', TodoCalCtrl]
angular.module('starter.controller').controller 'MyTodoListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', '$ionicViewSwitcher', 'model', MyTodoListCtrl]


angular.module('starter.controller').filter 'todosFilter', TodosFilter