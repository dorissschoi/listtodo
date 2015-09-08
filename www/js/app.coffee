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
	
    
	# My todo list
	$stateProvider.state 'app.mytodo',
		url: "/todo/mytodo"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/mylist.html"
				controller: 'MyTodoListCtrl'
		onEnter: ($state, $rootScope) ->
				$rootScope.$broadcast 'todo:mylistChanged'				    
    		
	# My upcoming todo list
	$stateProvider.state 'app.upcomingList',
		url: "/todo/upcomingList"
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/upcominglist.html"
				controller: 'UpcomingListCtrl'
    		
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
								
	$stateProvider.state 'app.calTodo',
		url: "/todo/cal"
		params: SelectedTodoView: 'month'
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/cal.html"
				controller: 'TodoCalCtrl'
		onEnter: ($state, $rootScope) ->
				$rootScope.$broadcast 'todo:mylistChanged'			

	$stateProvider.state 'app.weekTodo',
		url: "/todo/cal"
		params: SelectedTodoView: 'week'
		cache: false
		views:
			'menuContent':
				templateUrl: "templates/todo/cal.html"
				controller: 'TodoCalCtrl'
		onEnter: ($state, $rootScope) ->
				$rootScope.$broadcast 'todo:mylistChanged'			
	
						
														
	$urlRouterProvider.otherwise('/todo/upcomingList')
	