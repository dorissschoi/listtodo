module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'angularFileUpload', 'ngTouch', 'ngAnimate', 'ionic-datepicker', 'ionic-timepicker', 'mwl.calendar'])

module.run ($ionicPlatform, $location, $http, authService) ->
	$ionicPlatform.ready ->
		if (window.cordova && window.cordova.plugins.Keyboard)
			cordova.plugins.Keyboard.hideKeyboardAccessoryBar(true)
		if (window.StatusBar)
			StatusBar.styleDefault()
		
	# set authorization header once browser authentication completed
	if $location.url().match /access_token/
			data = $.deparam $location.url().split("/")[1]
			$http.defaults.headers.common.Authorization = "Bearer #{data.access_token}"
			authService.loginConfirmed()
		
module.config ($stateProvider, $urlRouterProvider) ->
	    
	$stateProvider.state 'app',
		url: ""
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"
		
	$stateProvider.state 'app.search',
		url: "/search"
		views:
			'menuContent':
				templateUrl: "templates/search.html"
   
    # My todo list page
	$stateProvider.state 'app.mytodopage',
		url: "/todo/mytodopage"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/mylistpage.html"
				controller: 'MyTodoListPageCtrl'

	$stateProvider.state 'app.createTodo',
		url: "/todo/create"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/create.html"
				controller: 'TodoCtrl'
	
	$stateProvider.state 'app.readTodo',
		url: "/todo/read"
		params: SelectedTodo: null, myTodoCol: null, backpage: null
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/read.html"
				controller: 'TodoReadCtrl'
				
	$stateProvider.state 'app.editTodo',
		url: "/todo/edit"
		params: SelectedTodo: null, myTodoCol: null, backpage: null
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/edit.html"
				controller: 'TodoEditCtrl'				

	# My todo day
	$stateProvider.state 'app.today',
		url: "/todo/today"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/today.html"
				controller: 'TodayCtrl'
					
	# My todo week
	$stateProvider.state 'app.week',
		url: "/todo/week"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/week.html"
				controller: 'WeekCtrl'											
	
	# My todo group by project
	$stateProvider.state 'app.projectTodo',
		url: "/todo/project"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/project.html"
				controller: 'ProjectTodoCtrl'

	# My todo day
	$stateProvider.state 'app.todayList',
		url: "/todo/todayList"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/todaylist.html"
				controller: 'TodayListCtrl'

	# My todo completed
	$stateProvider.state 'app.completedList',
		url: "/todo/completedList"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/completedlist.html"
				controller: 'CompletedListCtrl'									
	
	$urlRouterProvider.otherwise('/todo/todayList')				
	#$urlRouterProvider.otherwise('/todo/completedList')
	#$urlRouterProvider.otherwise('/todo/mytodopage')
	
	