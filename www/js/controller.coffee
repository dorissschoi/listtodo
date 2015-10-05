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
			$scope.model.newdateStart = $scope.datepickerObjectStart.inputDate
			$scope.model.newdateEnd = $scope.datepickerObjectEnd.inputDate
			$scope.model.newtimeStart = $scope.timePickerStartObject.inputEpochTime
			$scope.model.newtimeEnd = $scope.timePickerEndObject.inputEpochTime
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
	$scope.model.newproject = $scope.model.project
	$scope.model.newnotes = $scope.model.notes
	newdate = new Date($filter('date')($scope.model.dateStart, 'MMM dd yyyy UTC'))
	
	# ionic-datepicker 0.9
	currDate = new Date
	$scope.datepickerObjectStart = {
		titleLabel: 'start date',
		inputDate: newdate,
		callback: (val) ->
			$scope.datePickerStartCallback(val)
	}
	$scope.datePickerStartCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectStart.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectStart.inputDate = val
			if $scope.datepickerObjectEnd.inputDate < val
				$scope.datepickerObjectEnd.inputDate = val
		return
		
	newdate = new Date($filter('date')($scope.model.dateEnd, 'MMM dd yyyy UTC'))
		
	$scope.datepickerObjectEnd = {
		titleLabel: 'end date',
		inputDate: newdate,
		callback: (val) ->
			$scope.datePickerEndCallback(val)
	}	
	$scope.datePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectEnd.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectEnd.inputDate = val
			if $scope.datepickerObjectStart.inputDate > val
				$scope.datepickerObjectStart.inputDate = val
		return

	# ionic-timepicker 0.3
	$scope.timePickerStartObject = {
		inputEpochTime: $scope.model.dateStart.getHours()*60*60 + $scope.model.dateStart.getMinutes()*60,  
		step: 30,  
		format: 12,  
		titleLabel: 'start time',  
		callback: (val) ->   
			$scope.timePickernewStartCallback(val)
	}
	
	$scope.timePickernewStartCallback = (val) ->
		if typeof val != 'undefined'
			$scope.timePickerStartObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerEndObject.inputEpochTime < val
					$scope.timePickerEndObject.inputEpochTime = val
		return
	
	$scope.timePickerEndObject = {
		inputEpochTime: $scope.model.dateEnd.getHours()*60*60 + $scope.model.dateEnd.getMinutes()*60,  
		step: 30,  
		format: 12,  
		titleLabel: 'end time',  
		callback: (val) ->   
			$scope.timePickernewEndCallback(val)
	}	
	
	$scope.timePickernewEndCallback = (val) ->
		if typeof val != 'undefined'
			$scope.timePickerEndObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerStartObject.inputEpochTime > val
					$scope.timePickerStartObject.inputEpochTime = val
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
			$scope.endDate = $scope.datepickerObjectEnd.inputDate
			$scope.startDate = $scope.datepickerObjectStart.inputDate
			$scope.startTime = $scope.timePickerStartObject.inputEpochTime
			$scope.endTime = $scope.timePickerEndObject.inputEpochTime
			output = new Date($scope.startDate.getFullYear(),$scope.startDate.getMonth(), $scope.startDate.getDate(), parseInt($scope.startTime / 3600), $scope.startTime / 60 % 60)
			@model.dateStart = output
			output = new Date($scope.endDate.getFullYear(),  $scope.endDate.getMonth(),   $scope.endDate.getDate(), parseInt($scope.endTime / 3600), $scope.endTime / 60 % 60)
			@model.dateEnd = output
			@model.$save().catch alert
			$scope.todo.task = ''
			#$rootScope.$broadcast 'todo:getUpcomingListView'
			$state.go 'app.upcomingList', {}, { reload: true, cache: false }
		
	$scope.controller = new TodoView model: $scope.model
	
	# ionic-datepicker 0.9
	currDate = new Date
	$scope.datepickerObjectStart = {
		titleLabel: 'start date',
		inputDate: new Date,
		callback: (val) ->
			$scope.datePickerStartCallback(val)
	}
	
	$scope.datePickerStartCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectStart.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectStart.inputDate = val
			if $scope.datepickerObjectEnd.inputDate < val
				$scope.datepickerObjectEnd.inputDate = val
		return
		
	$scope.datepickerObjectEnd = {
		titleLabel: 'end date',
		inputDate: new Date,
		callback: (val) ->
			$scope.datePickerEndCallback(val)
	}	
	$scope.datePickerEndCallback = (val) ->
		if typeof val == 'undefined'
			$scope.datepickerObjectEnd.inputDate = new Date($filter('date')(currDate, 'MMM dd yyyy UTC'))
		else
			$scope.datepickerObjectEnd.inputDate = val
			if $scope.datepickerObjectStart.inputDate > val
				$scope.datepickerObjectStart.inputDate = val
		return
	
	# ionic-timepicker 0.3
	$scope.timePickerStartObject = {
		inputEpochTime: ((new Date()).getHours() * 60 * 60),  
		step: 30,  
		format: 12,  
		titleLabel: 'start time',  
		callback: (val) ->   
			$scope.timePickerStartCallback(val)
	}
	
	$scope.timePickerStartCallback = (val) ->
		if typeof val == 'undefined'
			$scope.timePickerStartObject.inputEpochTime = 0
		else 	
			$scope.timePickerStartObject.inputEpochTime = val
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerEndObject.inputEpochTime < val
					$scope.timePickerEndObject.inputEpochTime = val
		return
	
	$scope.timePickerEndObject = {
		inputEpochTime: ((new Date()).getHours() * 60 * 60),  
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
			adate = $scope.datepickerObjectStart.inputDate
			adate.setHours(0,0,0,0)
			bdate = $scope.datepickerObjectEnd.inputDate
			bdate.setHours(0,0,0,0)
			if (adate - bdate) == 0
				if $scope.timePickerStartObject.inputEpochTime > val
					$scope.timePickerStartObject.inputEpochTime = val
		return

	$scope.controllername = 'TodoCtrl'
				
			
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

TodayCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class TodayView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		timeRuler: () ->
			timeHeight = new Date()
			return timeHeight.getHours()*84 + (timeHeight.getMinutes() / 60) * 84
			
		previousDay: ->
			$scope.today = $scope.today.setDate($scope.today.getDate()-1)
			$scope.today = new Date($scope.today)
			$scope.fmDate = new Date($scope.today)
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = new Date($scope.today)
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'todo:getTodayView'		
		
		nextDay: ->
			$scope.today = $scope.today.setDate($scope.today.getDate()+1)
			$scope.today = new Date($scope.today)
			$scope.fmDate = new Date($scope.today)
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = new Date($scope.today)
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'todo:getTodayView'	
			
		remove: (todo) ->
			@collection.remove(todo)
			$rootScope.$broadcast 'todo:getTodayView'
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.today' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.today' }, { reload: true }

	$rootScope.$on 'todo:getTodayView', ->
		#start
		$scope.collection = new model.TodoRangeList()
		$scope.collection.$fetch({params: {fmDate: $scope.fmDate, toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
	
	$scope.reorder = ->
		#expand day range task
		$scope.events = []
		divLeft = 0
		Etot = $scope.collection.models.length  
		Ecnt = 1
		angular.forEach $scope.collection.models, (element) ->
			@newmodel = new model.Todo element
			#adjust fmDate, toDate
			if element.dateStart < $scope.fmDate
				@newmodel.dateStart = $scope.fmDate
			if element.dateEnd > $scope.toDate
				@newmodel.dateEnd = $scope.toDate
			
			#top: hour * 84 + per 30 mins * 1.4 (42px)
			@newmodel.top = @newmodel.dateStart.getHours()*84 + @newmodel.dateStart.getMinutes() *1.4
			
			#left: default -1px
			@newmodel.left = divLeft
			divLeft = (100 / Etot) * Ecnt
			
			#width: default 100 / nof events
			@newmodel.width = 100 / Etot
			
			#height: per 30 min * 21 
			diff = @newmodel.dateEnd - @newmodel.dateStart
			#half hour task
			if diff == 0
				@newmodel.height = 42
			else if @newmodel.dateEnd.getMinutes() == 59
				@newmodel.height = (Math.floor(diff/1000/60) / 30 +1) * 42
			else	
				@newmodel.height = (Math.floor(diff/1000/60) / 30) * 42
			
			$scope.events.push @newmodel
			Ecnt = Ecnt + 1
		
		$scope.collection.todos = $scope.events
		$scope.controller = new TodayView collection: $scope.collection	
			
	#start here
	$scope.today = new Date()
	$scope.fmDate = new Date()
	$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
	$scope.toDate = new Date()
	$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
	$rootScope.$broadcast 'todo:getTodayView'	


WeekCtrl = ($rootScope, $scope, $state, $stateParams, $location, $filter, model) ->
	class WeekView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		previousWeek: ->
			curr = new Date($scope.week[0])
			curr = curr.setDate(curr.getDate() - 7)
			$scope.week = $scope.getWeek(new Date(curr))
			$scope.today = new Date()
		
			$scope.fmDate = $scope.week[0]
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = $scope.week[6]
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'todo:getWeekView'

		nextWeek: ->
			curr = new Date($scope.week[0])
			curr = curr.setDate(curr.getDate() + 7)
			$scope.week = $scope.getWeek(new Date(curr))
			$scope.today = new Date()
		
			$scope.fmDate = $scope.week[0]
			$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
			$scope.toDate = $scope.week[6]
			$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
			$rootScope.$broadcast 'todo:getWeekView'
			
		isToday: (d) ->
			today = new Date
			today.setHours(0,0,0,0)
			iDate = new Date(d)
			iDate.setHours(0,0,0,0)
			return today.getTime() == iDate.getTime()
			
		remove: (todo) ->
			@collection.remove(todo)
			$rootScope.$broadcast 'todo:getWeekView'
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.week' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.week' }, { reload: true }

	$rootScope.$on 'todo:getWeekView', ->
		#start
		$scope.collection = new model.TodoRangeList()
		$scope.collection.$fetch({params: {fmDate: $scope.fmDate, toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				#$scope.reorder()
				$scope.wkreorder()
		#end		
	
	
	$scope.wkreorder = ->
		#find todo day by day
		i = 0
		wktodo = []
		$scope.wktodo = new Array()
		while i < 7
		  $scope.dayStart = $scope.week[i]
		  $scope.dayStart = new Date($scope.dayStart.setHours(0,0,0,0))
		  $scope.dayEnd = $scope.week[i]
		  $scope.dayEnd = new Date($scope.dayEnd.setHours(23,59,0,0))
		  #if in a day, (StartA < EndB)  and  (EndA > StartB)
		  angular.forEach $scope.collection.models, (element) ->
		    if ((element.dateStart <= $scope.dayEnd) and (element.dateEnd >= $scope.dayStart))
		      wktodo.push element
		  $scope.curr = i  
		  $scope.wktodo[$scope.curr] = wktodo
		  wktodo = [] 
		  $scope.reorder() 
		  i++
		  
	$scope.reorder = ->
		#expand day range task
		$scope.events = []
		divLeft = 0
		Etot = $scope.wktodo[$scope.curr].length   
		Ecnt = 1
		angular.forEach $scope.wktodo[$scope.curr], (element) ->
			@newmodel = new model.Todo element
			#adjust fmDate, toDate
			if element.dateStart < $scope.dayStart
				@newmodel.dateStart = $scope.dayStart
			if element.dateEnd > $scope.dayEnd
				@newmodel.dateEnd = $scope.dayEnd
			
			#top: hour * 84 + per 30 mins * 1.4 (42px)
			@newmodel.top = @newmodel.dateStart.getHours()*84 + @newmodel.dateStart.getMinutes() *1.4
			
			#left: default -1px
			@newmodel.left = divLeft
			divLeft = (100 / Etot) * Ecnt
			
			#width: default 100 / nof events
			@newmodel.width = 100 / Etot
			
			#height: per 30 min * 21 
			diff = @newmodel.dateEnd - @newmodel.dateStart
			#half hour task
			if diff == 0
				@newmodel.height = 42
			else if @newmodel.dateEnd.getMinutes() == 59
				@newmodel.height = (Math.floor(diff/1000/60) / 30 +1) * 42
			else	
				@newmodel.height = (Math.floor(diff/1000/60) / 30) * 42
			
			$scope.events.push @newmodel
			Ecnt = Ecnt + 1
		
		$scope.collection.todos = $scope.events
		$scope.weektodo[$scope.curr] = $scope.events
		$scope.controller = new WeekView collection: $scope.collection	

	$scope.getWeek = (fromDate) ->
		sunday = new Date(fromDate.setDate(fromDate.getDate() - fromDate.getDay()))
		result = [ new Date(sunday) ]
		while sunday.setDate(sunday.getDate() + 1) and sunday.getDay() != 0
		  result.push new Date(sunday)
		result
				
	#start here
	$scope.weektodo = new Array()
	$scope.week = $scope.getWeek(new Date())
	$scope.today = new Date()
	$scope.curr = 0
	$scope.fmDate = $scope.week[0]
	$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
	$scope.toDate = $scope.week[6]
	$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
	$rootScope.$broadcast 'todo:getWeekView'

										
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

angular.module('starter.controller').controller 'TodoEditCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', '$filter', TodoEditCtrl]
angular.module('starter.controller').controller 'TodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', '$filter', TodoCtrl]

angular.module('starter.controller').controller 'MyTodoListPageCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', 'model', MyTodoListPageCtrl]
angular.module('starter.controller').controller 'UpcomingListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', UpcomingListCtrl]
angular.module('starter.controller').controller 'ProjectTodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', ProjectTodoCtrl]

angular.module('starter.controller').controller 'WeekCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', WeekCtrl]
angular.module('starter.controller').controller 'TodayCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$filter', 'model', TodayCtrl]

angular.module('starter.controller').filter 'todosFilter', TodosFilter

angular.module('starter.controller').directive 'standardTimeMeridian', standardTimeMeridian 
