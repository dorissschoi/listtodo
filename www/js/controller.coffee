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
			
			# ionic-datepicker
			$scope.slots = [{epochTime: 0, format: 12, step: 15},{epochTime: 0, format: 12, step: 15}]
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

		update: ->
			@model = $scope.model		
			@model.task = $scope.model.newtask
			@model.location = $scope.model.newlocation
			output = new Date($scope.model.newdateStart.getFullYear(),$scope.model.newdateStart.getMonth(), $scope.model.newdateStart.getDate(), parseInt($scope.model.newtimeStart / 3600), $scope.model.newtimeStart / 60 % 60)
			@model.dateStart = output
			output = new Date($scope.model.newdateEnd.getFullYear(),$scope.model.newdateEnd.getMonth(), $scope.model.newdateEnd.getDate(), parseInt($scope.model.newtimeEnd / 3600), $scope.model.newtimeEnd / 60 % 60)
			@model.dateEnd = output 
			@model.$save().then =>
				$state.go 'app.upcomingList', {}, { reload: true }
				
		backpage: ->
			if _.isNull $stateParams.backpage
				$state.go $rootScope.URL, {}, { reload: true }
			else	
				$state.go $stateParams.backpage, {}, { reload: true }
			
	$scope.collection = $stateParams.myTodoCol
	$scope.model = $stateParams.SelectedTodo
	$scope.model.newtask = $scope.model.task
	$scope.model.newlocation = $scope.model.location
	newdate = new Date($filter('date')($scope.model.dateStart, 'MMM dd yyyy UTC'))
	$scope.model.newdateStart = newdate
	newdate = new Date($filter('date')($scope.model.dateEnd, 'MMM dd yyyy UTC'))
	$scope.model.newdateEnd = newdate
	$scope.model.newtimeStart = $scope.model.dateStart.getHours()*60*60 + $scope.model.dateStart.getMinutes()*60
	$scope.model.newtimeEnd = $scope.model.dateEnd.getHours()*60*60 + $scope.model.dateEnd.getMinutes()*60
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
			@model.location = $scope.todo.location
			output = new Date($scope.startDate.getFullYear(),$scope.startDate.getMonth(), $scope.startDate.getDate(), parseInt($scope.startTime / 3600), $scope.startTime / 60 % 60)
			@model.dateStart = output
			output = new Date($scope.endDate.getFullYear(),  $scope.endDate.getMonth(),   $scope.endDate.getDate(), parseInt($scope.endTime / 3600), $scope.endTime / 60 % 60)
			@model.dateEnd = output
			@model.$save().catch alert
			$scope.todo.task = ''
			#$rootScope.$broadcast 'todo:mylistCalChanged'
			$state.go 'app.upcomingList', {}, { reload: true, cache: false }
		
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


TodoCalCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, model) ->
	class TodoCalView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection
		
		# refresh new add task
		$rootScope.$on 'todo:mylistCalChanged', ->
			$scope.collection = new model.MyTodoList()
			$scope.collection.$fetch()
			$ionicHistory.nextViewOptions({historyRoot: true})
			$ionicHistory.clearCache()
			
	$scope.collection = new model.MyTodoList()
	$scope.collection.$fetch().then =>
		$scope.controller = new TodoCalView collection: $scope.collection
		angular.forEach $scope.collection.models, (element) ->
        	#convert data to suit the calendar format
			$scope.events.push
				title: element.task,
				type: 'info',
				startsAt: element.dateStart,
				endsAt: element.dateEnd
				editable: false,
				deletable: false,
				draggable: false,
				resizable: false,
				id: element._id,
				dateStart: element.dateStart,
				dateEnd: element.dateEnd,
				task: element.task
			return
		$scope.$apply()

	#Start Angular Calendar
	#These variables MUST be set as a minimum for the calendar to work
	if !_.isUndefined($stateParams.SelectedTodoView)
		$scope.calendarView = $stateParams.SelectedTodoView
	else	
		$scope.calendarView = 'month'
	$scope.calendarDay = new Date()

	# click to read todo
	$scope.eventClicked = (event) ->
		if $scope.calendarView == 'month'
			$rootScope.URL = 'app.calTodo'
		else if $scope.calendarView == 'week'
			$rootScope.URL = 'app.weekTodo'
		else if $scope.calendarView == 'day'
			$rootScope.URL = 'app.dayTodo'
		else if $scope.calendarView == 'year'
			$rootScope.URL = 'app.yearTodo'			
		$state.go 'app.readTodo', { SelectedTodo: event , myTodoCol: $scope.collection.models}, {reload: true}
		

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
	
	$rootScope.URL = 'app.upcomingList'						
	$scope.collection = new model.MyTodoList()
	$scope.collection.$fetch()
	$scope.controller = new MyTodoListView collection: $scope.collection

UpcomingListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, $filter, model) ->
	class UpcomingListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$scope.collection = new model.UpcomingList()
			#start
			$scope.collection.$fetch().then ->
				$scope.$apply ->
					#expand day range task
					$scope.events = []
					oneDay = 24*60*60*1000
					angular.forEach $scope.collection.models, (element) ->
						sdate = new Date(element.dateStart)
						sdate = new Date(sdate.setHours(0,0,0,0))
						edate = new Date(element.dateEnd)
						edate = new Date(edate.setHours(0,0,0,0))
								
						diffDays = Math.round(Math.abs((sdate.getTime() - edate.getTime())/(oneDay)))
						tomorrow = new Date(element.dateStart)
						tomorrow = new Date(tomorrow.setHours(0,0,0,0))
						i=0
						while i <= diffDays
							@newmodel = new model.Todo element
							@newmodel.oStDate = tomorrow
							if i == 0
								@newmodel.oStTime = element.dateStart
								@newmodel.oStDate = sdate
							else
								tomorrow = new Date(tomorrow.setDate(tomorrow.getDate()+1))
								@newmodel.oStTime = tomorrow
									
							if diffDays == i	
								@newmodel.oEnTime = element.dateEnd
							
							if i < diffDays 
								dayEnd = new Date(@newmodel.oStDate)
								dayEnd = new Date(dayEnd.setHours(23,59,0,0))
								@newmodel.oEnTime = dayEnd 
									
							$scope.events.push @newmodel
							i++
							
					#grouping
					$scope.eventsGP = _.groupBy($scope.events,'oStDate')
					
					#new groupby
					$scope.groupedByDate = _.groupBy($scope.events, (item) ->
						item.oStDate.setHours(0,0,0,0)
					)	
						#item.getFullYear() + item.getMonth() + item.getDate() + "-" + item 
											
					$scope.collection.todos = $scope.groupedByDate
					$scope.controller = new UpcomingListView collection: $scope.collection
			#end
					
			
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.mytodo' }, { reload: true }

		$scope.formatDate = (inStr, format) ->
			inStr = new Date(parseInt(inStr))
			return $filter("date")(inStr, format)
			
		
	$scope.collection = new model.UpcomingList()
	$scope.collection.$fetch().then ->
		$scope.$apply ->
			#expand day range task
			$scope.events = []
			oneDay = 24*60*60*1000
			angular.forEach $scope.collection.models, (element) ->
				sdate = new Date(element.dateStart)
				sdate = new Date(sdate.setHours(0,0,0,0))
				edate = new Date(element.dateEnd)
				edate = new Date(edate.setHours(0,0,0,0))
						
				diffDays = Math.round(Math.abs((sdate.getTime() - edate.getTime())/(oneDay)))
				tomorrow = new Date(element.dateStart)
				tomorrow = new Date(tomorrow.setHours(0,0,0,0))
				i=0
				while i <= diffDays
					@newmodel = new model.Todo element
					@newmodel.oStDate = tomorrow
					if i == 0
						@newmodel.oStTime = element.dateStart
						@newmodel.oStDate = sdate
					else
						tomorrow = new Date(tomorrow.setDate(tomorrow.getDate()+1))
						@newmodel.oStTime = tomorrow
							
					if diffDays == i	
						@newmodel.oEnTime = element.dateEnd
					
					if i < diffDays 
						dayEnd = new Date(@newmodel.oStDate)
						dayEnd = new Date(dayEnd.setHours(23,59,0,0))
						@newmodel.oEnTime = dayEnd 
							
					$scope.events.push @newmodel
					i++
					
			#grouping
			$scope.eventsGP = _.groupBy($scope.events,'oStDate')
			
			#new groupby
			$scope.groupedByDate = _.groupBy($scope.events, (item) ->
				item.oStDate.setHours(0,0,0,0)
			)	
				#item.getFullYear() + item.getMonth() + item.getDate() + "-" + item 
									
			$scope.collection.todos = $scope.groupedByDate
			$scope.controller = new UpcomingListView collection: $scope.collection
	
								
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

angular.module('starter.controller').controller 'TodoCalCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', 'model', TodoCalCtrl]

angular.module('starter.controller').controller 'MyTodoListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', 'model', MyTodoListCtrl]
angular.module('starter.controller').controller 'UpcomingListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', '$filter', 'model', UpcomingListCtrl]

angular.module('starter.controller').filter 'todosFilter', TodosFilter

angular.module('starter.controller').directive 'standardTimeMeridian', standardTimeMeridian 
