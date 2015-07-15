module = angular.module('starter', ['ionic', 'starter.controller', 'http-auth-interceptor', 'ngTagEditor', 'ActiveRecord', 'angularFileUpload', 'ngTouch', 'ngAnimate', 'ui.bootstrap', 'mwl.calendar'])

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
		url: "/file"
		abstract: true
		controller: 'AppCtrl'
		templateUrl: "templates/menu.html"
		
	$stateProvider.state 'app.search',
		url: "/search"
		views:
			'menuContent':
				templateUrl: "templates/search.html"
	
	$stateProvider.state 'app.permission',
		url: "/permission"
		views:
			'menuContent':
				templateUrl: "templates/permission/list.html"
				controller: "AclCtrl"

	$stateProvider.state 'app.file',
		url: "/file?path"
		views:
			'menuContent':
				templateUrl: "templates/file/list.html"
				controller: 'FileCtrl'

	$stateProvider.state 'app.todo',
		url: "/todo"
		views:
			'menuContent':
				templateUrl: "templates/todo/list.html"
				controller: 'TodoListCtrl'
		#onEnter: ($state, $rootScope) ->
		#		$rootScope.$broadcast 'todo:listChanged'
    		
	
	
	$stateProvider.state 'app.createTodo',
		url: "/todo/create"
		views:
			'menuContent':
				templateUrl: "templates/todo/create.html"
				controller: 'TodoCtrl'
	
	$stateProvider.state 'app.calTodo',
		url: "/todo/cal"
		views:
			'menuContent':
				templateUrl: "templates/todo/cal.html"
				controller: 'TodoCalCtrl'
	
														
	$urlRouterProvider.otherwise('/file/file')