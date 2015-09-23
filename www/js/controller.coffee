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
					
TodoEditCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, model, $filter) ->
	class TodoEditView  			

		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			
		update: ->
			@model = $scope.model		
			@model.task = $scope.model.newtask
			@model.location = $scope.model.newlocation
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
			#$rootScope.$broadcast 'todo:mylistCalChanged'
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
				
			
MyTodoListPageCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, model) ->
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
		

UpcomingListCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, $filter, model) ->
	class UpcomingListView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$rootScope.$broadcast 'todo:getListView'
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.mytodo' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.mytodo' }, { reload: true }

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

CalCtrl = ($rootScope, $scope, $state, $stateParams, $location, $ionicModal, $ionicHistory, $filter, model) ->
	class CalView
		constructor: (opts = {}) ->
			_.each @events, (handler, event) =>
				$scope.$on event, @[handler]
			@collection = opts.collection

		remove: (todo) ->
			@collection.remove(todo)
			$rootScope.$broadcast 'todo:getListView'
			
		read: (selectedModel) ->
			$state.go 'app.readTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.mytodo' }, { reload: true }

		edit: (selectedModel) ->
			$state.go 'app.editTodo', { SelectedTodo: selectedModel, myTodoCol: null, backpage: 'app.mytodo' }, { reload: true }

		$scope.formatDate = (inStr, format) ->
			inStr = new Date(parseInt(inStr))
			return $filter("date")(inStr, format)

	$rootScope.$on 'todo:getCalView', ->
		#start
		$scope.collection = new model.TodoRangeList()
		$scope.collection.$fetch({params: {fmDate: $scope.fmDate, toDate: $scope.toDate}}).then ->
			$scope.$apply ->
				$scope.reorder()
		#end		
	
	
	$scope.reorder = ->
		#expand day range task
		$scope.events = []
		angular.forEach $scope.collection.models, (element) ->
			@newmodel = new model.Todo element
			#adjust fmDate, toDate
			if element.dateStart < $scope.fmDate
				@newmodel.dateStart = $scope.fmDate
			if element.dateEnd > $scope.toDate
				@newmodel.dateEnd = $scope.toDate
			
			#day30MinHeight = 21px
			MHeight = 21
			HHeight = 2 * MHeight
			
			#top: hour * 42 + per 30 mins * 21 
			@newmodel.top = @newmodel.dateStart.getHours()*42 + @newmodel.dateStart.getMinutes() *.7
			
			#left: default -1px
			@newmodel.left = "-1px"
			
			#width: default 100
			@newmodel.width = 100
			
			#height: per 30 min * 21 
			diff = @newmodel.dateEnd - @newmodel.dateStart
			#half hour task
			if diff == 0
				@newmodel.height = 21
			else if @newmodel.dateEnd.getMinutes() == 59
				@newmodel.height = (Math.floor(diff/1000/60) / 30 +1) * 21
			else	
				@newmodel.height = (Math.floor(diff/1000/60) / 30) * 21
			
			$scope.events.push @newmodel
		
		#find intersect, adjust left/height/width
		#(StartA < EndB)  and  (EndA > StartB)
		
		a = $scope.events
		i = 0
		tot = a.length  
		while i < tot
		  console.log a[i]
		  j = i 
		  gpArray = []
		  while j < tot
		    if a[i]._id != a[j]._id
		      if ((a[i].dateStart < a[j].dateEnd) and (a[i].dateEnd > a[j].dateStart)) 
		        gpArray.push i
		        gpArray.push j
		    gpArray = _.uniq(gpArray)
		    j++
		    
		  #remove previous gp  
		  k = 0
		  ktot = gpArray.length
		  newArray = []
		  while k < ktot
		    if a[gpArray[k]].width == 100
		        newArray.push gpArray[k]
		    k++
		  gpArray = newArray
		  
		  #chk intersect again
		  k = 0
		  ktot = parseInt(gpArray.length-1)
		  newArray = []
		  if ktot > 0
		    while k < ktot 
		      if ((a[gpArray[k]].dateStart < a[gpArray[k+1]].dateEnd) and (a[gpArray[k]].dateEnd > a[gpArray[k+1]].dateStart)) 
		        newArray.push gpArray[k]
		        newArray.push gpArray[k+1]
		      newArray = _.uniq(newArray)
		      k++
		  gpArray = newArray
		      
		  #adjust width
		  k = 0
		  ktot = gpArray.length
		  while k < ktot
		    if k == parseInt(ktot-1)
		      a[gpArray[k]].width = (100 / ktot)
		    else
		      a[gpArray[k]].width = (100 / ktot) * 1.7  
		    k++  
		  #adjust left
		  k = 0
		  first = false
		  while k < ktot
		    if first
		      a[gpArray[k]].left = (100/ ktot *k)+"%"
		      a[gpArray[k]].style = "chip-border"
		    if a[gpArray[k]].left == "-1px"
		      first = true
		    k++
		     
		  i++
		  			
		$scope.collection.todos = $scope.events
		$scope.controller = new CalView collection: $scope.collection	
			
	#start here
	$scope.fmDate = new Date()
	$scope.fmDate = new Date($scope.fmDate.setHours(0,0,0,0))
	$scope.toDate = new Date()
	$scope.toDate = new Date($scope.toDate.setHours(23,59,0,0))
	$rootScope.$broadcast 'todo:getCalView'	
								
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

angular.module('starter.controller').controller 'TodoEditCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', '$filter', TodoEditCtrl]
angular.module('starter.controller').controller 'TodoCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', 'model', '$filter', TodoCtrl]

angular.module('starter.controller').controller 'MyTodoListPageCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', 'model', MyTodoListPageCtrl]
angular.module('starter.controller').controller 'UpcomingListCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', '$filter', 'model', UpcomingListCtrl]

angular.module('starter.controller').controller 'CalCtrl', ['$rootScope', '$scope', '$state', '$stateParams', '$location', '$ionicModal', '$ionicHistory', '$filter', 'model', CalCtrl]


angular.module('starter.controller').filter 'todosFilter', TodosFilter

angular.module('starter.controller').directive 'standardTimeMeridian', standardTimeMeridian 
