env = require './env.coffee'


	
MenuCtrl = ($scope) ->
	$scope.env = env
	$scope.navigator = navigator
					
TodoEditCtrl = ($rootScope, $scope, $state, $stateParams, $location, model, $filter) ->
	class TodoEditView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: ->
			@model = $scope.model		
			@model.task = $scope.model.newtask
			@model.location = $scope.model.newlocation
			@model.project = $scope.model.newproject
			@model.notes = $scope.model.newnotes

			if !_.isUndefined($scope.datepickerObjectEnd.inputDate)
				$scope.model.newdateEnd = $scope.datepickerObjectEnd.inputDate
				$scope.model.newtimeEnd = $scope.timePickerEndObject.inputEpochTime
				output = new Date($scope.model.newdateEnd.getFullYear(),$scope.model.newdateEnd.getMonth(), $scope.model.newdateEnd.getDate(), parseInt($scope.model.newtimeEnd / 3600), $scope.model.newtimeEnd / 60 % 60)
				@model.dateEnd = output
			else @model.dateEnd = null
					 
			@model.$save().then =>
				$state.go 'app.todayList', {}, { reload: true }
				
		backpage: ->
			if _.isNull $stateParams.backpage
				$state.go $rootScope.URL, {}, { reload: true }
			else	
				$state.go $stateParams.backpage, {}, { reload: true }
			
	
	$scope.model = $stateParams.SelectedTodo
	$scope.model.newtask = $scope.model.task
	$scope.model.newlocation = $scope.model.location
	$scope.model.newproject = $scope.model.project
	$scope.model.newnotes = $scope.model.notes
	
	# ionic-datepicker 0.9
	currDate = new Date
	#if !_.isUndefined($scope.model.dateEnd)
	if !_.isNull($scope.model.dateEnd)
		newdate = new Date($filter('date')($scope.model.dateEnd, 'MMM dd yyyy UTC'))
		#$scope.model.dateEnd = currDate
		
	$scope.datepickerObjectEnd = {
		titleLabel: 'end date',
		inputDate: newdate,
		callback: (val) ->
			$scope.datePickerEndCallback(val)
	}	
	$scope.datePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectEnd.inputDate = val
			$scope.timePickerEndObject.inputEpochTime = null
		else
			$scope.datepickerObjectEnd.inputDate = val
			$scope.datepickerObjectEnd.date = val
			if _.isNull(newtime)
				currTime = new Date
				$scope.timePickerEndObject.inputEpochTime = currTime.getHours()*60*60 
		return

	# ionic-timepicker 0.3
	#if !_.isUndefined($scope.model.dateEnd)
	if !_.isNull($scope.model.dateEnd)
		newtime = $scope.model.dateEnd.getHours()*60*60 + $scope.model.dateEnd.getMinutes()*60
	else newtime = null	
	$scope.timePickerEndObject = {
		inputEpochTime: newtime,  
		step: 30,  
		format: 12,  
		titleLabel: 'end time',  
		callback: (val) ->   
			$scope.timePickernewEndCallback(val)
	}	
	
	$scope.timePickernewEndCallback = (val) ->
		if typeof val != 'undefined'
			$scope.timePickerEndObject.inputEpochTime = val
		return			
		
	$scope.controller = new TodoEditView model: $scope.model
	
TodoCtrl = ($rootScope, $scope, $state, $stateParams, $location, model, $filter) ->
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
			@model.project = $scope.todo.project
			@model.notes = $scope.todo.notes
			if !_.isUndefined($scope.datepickerObjectEnd.date)
				$scope.endDate = $scope.datepickerObjectEnd.date
				$scope.endTime = $scope.timePickerEndObject.inputEpochTime 
				output = new Date($scope.endDate.getFullYear(), $scope.endDate.getMonth(), $scope.endDate.getDate(), parseInt($scope.endTime / 3600), $scope.endTime / 60 % 60)
				@model.dateEnd = output
			else @model.dateEnd = null	
			@model.$save().catch alert
			$scope.todo.task = ''
			$scope.todo.dateEnd = null
			$scope.datepickerObjectEnd.inputDate = null
			$scope.timePickerEndObject.inputEpochTime = null
			$state.go 'app.todayList', {}, { reload: true, cache: false }
		
	$scope.controller = new TodoView model: $scope.model
	
	# ionic-datepicker 0.9
	$scope.currDate = new Date
	$scope.datepickerObjectEnd = {
		titleLabel: 'end date',
		inputDate: null,
		callback: (val) ->
			$scope.datePickerEndCallback(val)
	}	
	$scope.datePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectEnd.inputDate = null
			$scope.datepickerObjectEnd.date = val
			$scope.timePickerEndObject.inputEpochTime = null
		else
			$scope.datepickerObjectEnd.inputDate = val
			$scope.datepickerObjectEnd.date = val
			if _.isNull($scope.timePickerEndObject.inputEpochTime)
				currTime = new Date
				$scope.timePickerEndObject.inputEpochTime = currTime.getHours()*60*60 
		return
	
	# ionic-timepicker 0.3
	
	$scope.timePickerEndObject = {
		inputEpochTime: null,  
		step: 30,  
		format: 12,  
		titleLabel: 'end time',  
		callback: (val) ->   
			$scope.timePickerEndCallback(val)
	}	
	$scope.timePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.timePickerEndObject.inputEpochTime = 0
		else 	
			$scope.timePickerEndObject.inputEpochTime = val
		return

			
MyTodoListPageCtrl = ($rootScope, $scope, $state, $stateParams, $location, model) ->
	class MyTodoListPageView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@model.remove(todo)
	
	$scope.loadMore = ->
		$scope.collection.$fetch()
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
			.catch alert
					
	$scope.collection = new model.MyTodoList()
	$scope.collection.$fetch().then ->
		$scope.$apply ->	
			$scope.controller = new MyTodoListPageView collection: $scope.collection
		

UpcomingListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class UpcomingListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$rootScope.$broadcast 'todo:getUpcomingListView'
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.upcomingList' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.upcomingList' }, { reload: true }

		$scope.formatDate = (inStr, format) ->
			inStr = new Date(parseInt(inStr))
			return $filter("date")(inStr, format)

	$rootScope.$on 'todo:getUpcomingListView', ->
		#start
		$scope.collection = new model.UpcomingList()
		$scope.collection.$fetch().then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
		
	$rootScope.$on 'todo:refreshView', ->
		#start
		$scope.reorder()
		#end
		
	$scope.reorder = ->
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
											
		$scope.collection.todos = $scope.groupedByDate
		$scope.controller = new UpcomingListView collection: $scope.collection	
			
	$scope.loadMore = ->
		$scope.collection.$fetch()
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
				$scope.$apply ->
					$rootScope.$broadcast 'todo:refreshView'
			.catch alert
					
	$rootScope.$broadcast 'todo:getUpcomingListView'

ProjectTodoCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class ProjectTodoView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$rootScope.$broadcast 'todo:getProjectTodoView'
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.projectTodo' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.projectTodo' }, { reload: true }
		
		$scope.formatDate = (inStr, format) ->
			inStr = new Date(parseInt(inStr))
			return $filter("date")(inStr, format)

	$rootScope.$on 'todo:getProjectTodoView', ->
		#start
		$scope.collection = new model.UpcomingList()
		$scope.collection.$fetch({params: {order_by: 'project'}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
		
	$rootScope.$on 'todo:refreshProjectTodoView', ->
		#start
		$scope.reorder()
		#end
		
	$scope.reorder = ->
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
		group1 = _.groupBy($scope.events, (item) ->
			return item.project  
		)
		 
		$scope.p = []
		angular.forEach group1, (element) ->
			group2 = _.groupBy(element, (item) ->
				item.oStDate.setHours(0,0,0,0)
			)
			$scope.p.push {project : element[0].project, 	models : group2	}	
			
		
		$scope.collection.todos = $scope.p
		$scope.controller = new ProjectTodoView collection: $scope.collection	
			
	$scope.loadMore = ->
		$scope.collection.$fetch()
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
				$scope.$apply ->
					$rootScope.$broadcast 'todo:refreshProjectTodoView'
			.catch alert
					
	$rootScope.$broadcast 'todo:getProjectTodoView'



TodayListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class TodayListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$state.go($state.current, {}, { reload: true })	
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.todayList' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.todayList' }, { reload: true }

		setComplete: (selectedModel) ->
			@model = selectedModel
			@model.completed = 'true'
			@model.$save().then =>
				$scope.getTodayListView()

		$scope.formatDate = (inDate, format) ->
			inDate = new Date(parseInt(inDate))
			today = new Date()
			today = new Date(today.setHours(0,0,0,0))
			oneDay = 24*60*60*1000
			if (today.getTime() > inDate.getTime()) 
				diffDays = Math.round(-Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			else	
				diffDays = Math.round(Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			
			if diffDays < 0
				return "days before"
			else if diffDays == 0
				return "Today"
			else if diffDays == 1
				return "Tomorrow"
			else return $filter("date")(inDate, format)		 	

		$scope.formatDays = (inDate) ->
			inDate = new Date(parseInt(inDate))
			today = new Date()
			today = new Date(today.setHours(0,0,0,0))
			oneDay = 24*60*60*1000
			if (today.getTime() > inDate.getTime()) 
				diffDays = Math.round(-Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			else	
				diffDays = Math.round(Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			
			if diffDays < 0
				return Math.abs(diffDays)		 	

	$scope.isGroupShown = (item) ->
		$scope.shownGroup == item

	$scope.toggleGroup = (item) ->
		if $scope.isGroupShown(item)
			$scope.shownGroup = null
		else
			$scope.shownGroup = item
		return
	  				
	$scope.getTodayListView = ->
		#start
		$scope.collection = new model.TodayList()
		$scope.collection.$fetch({params: {toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		

	$scope.reorder = ->
				$scope.collection.todos = $scope.collection.models
				groupTodo = []
				$scope.groupTodoA = []		
				angular.forEach $scope.collection.models, (element) ->
					if _.isNull(element.dateEnd)
						$scope.groupTodoA.push element
					else
						edate = new Date(element.dateEnd)
						edate = new Date(edate.setHours(0,0,0,0))
						@newmodel = new model.Todo element
						@newmodel.edate = edate 
						groupTodo.push @newmodel	
				#new groupby
				$scope.groupedByDate = _.groupBy(groupTodo, (item) ->
					item.edate.setHours(0,0,0,0)
				)
				$scope.controller = new TodayListView collection: $scope.collection
				
	$scope.loadMore = ->
		$scope.collection.$fetch({params: {toDate: $scope.toDate}})
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
				$scope.$apply ->
					$scope.reorder()
			.catch alert
				
	#$scope.today = new Date()
	$scope.fmDate = new Date()
	$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
	$scope.toDate = new Date()
	$scope.toDate = new Date($scope.toDate.setDate($scope.toDate.getDate()+6))
	$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
	$scope.getTodayListView()

CompletedListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model ) ->
	class CompletedListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$state.go($state.current, {}, { reload: true })	
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.todayList' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.todayList' }, { reload: true }

		setUnComplete: (selectedModel) ->
			@model = selectedModel
			@model.completed = 'false'
			@model.$save().then =>
				$scope.getCompletedListView()

		$scope.formatDate = (inDate, format) ->
			inDate = new Date(parseInt(inDate))
			today = new Date()
			today = new Date(today.setHours(0,0,0,0))
			oneDay = 24*60*60*1000
			if (today.getTime() > inDate.getTime()) 
				diffDays = Math.round(-Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			else	
				diffDays = Math.round(Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			
			if diffDays < 0
				return "days before"
			else if diffDays == 0
				return "Today"
			else if diffDays == 1
				return "Tomorrow"
			else return $filter("date")(inDate, format)		 	

		$scope.formatDays = (inDate) ->
			inDate = new Date(parseInt(inDate))
			today = new Date()
			today = new Date(today.setHours(0,0,0,0))
			oneDay = 24*60*60*1000
			if (today.getTime() > inDate.getTime()) 
				diffDays = Math.round(-Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			else	
				diffDays = Math.round(Math.abs((today.getTime() - inDate.getTime())/(oneDay)))
			
			if diffDays < 0
				return Math.abs(diffDays)		 	

	$scope.isGroupShown = (item) ->
		$scope.shownGroup == item

	$scope.toggleGroup = (item) ->
		if $scope.isGroupShown(item)
			$scope.shownGroup = null
		else
			$scope.shownGroup = item
		return
	  				
	$scope.getCompletedListView = ->
		#start
		$scope.collection = new model.TodayList()
		$scope.collection.$fetch({params: {completed: Boolean('true'),toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		

	$scope.reorder = ->
				$scope.collection.todos = $scope.collection.models
				groupTodo = []
				$scope.groupTodoA = []		
				angular.forEach $scope.collection.models, (element) ->
					if _.isNull(element.dateEnd)
						$scope.groupTodoA.push element
					else
						edate = new Date(element.dateEnd)
						edate = new Date(edate.setHours(0,0,0,0))
						@newmodel = new model.Todo element
						@newmodel.edate = edate 
						groupTodo.push @newmodel	
				#new groupby
				$scope.groupedByDate = _.groupBy(groupTodo, (item) ->
					item.edate.setHours(0,0,0,0)
				)
				$scope.controller = new CompletedListView collection: $scope.collection
				
	$scope.loadMore = ->
		$scope.collection.$fetch({params: {completed: Boolean('true'),toDate: $scope.toDate}})
			.then ->
				$scope.$broadcast('scroll.infiniteScrollComplete')
				$scope.$apply ->
					$scope.reorder()
			.catch alert
				
	$scope.getCompletedListView()
	
										
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
angular.module('starter.controller').controller 'MenuCtrl', ['$scope', MenuCtrl]

angular.module('starter.controller').controller 'TodoEditCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', '$filter', TodoEditCtrl]
angular.module('starter.controller').controller 'TodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', '$filter', TodoCtrl]

angular.module('starter.controller').controller 'MyTodoListPageCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', MyTodoListPageCtrl]
angular.module('starter.controller').controller 'UpcomingListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', UpcomingListCtrl]
angular.module('starter.controller').controller 'ProjectTodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', ProjectTodoCtrl]


angular.module('starter.controller').controller 'TodayListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', TodayListCtrl]
angular.module('starter.controller').controller 'CompletedListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', CompletedListCtrl]

angular.module('starter.controller').filter 'todosFilter', TodosFilter
angular.module('starter.controller').directive 'standardTimeMeridian', standardTimeMeridian 
