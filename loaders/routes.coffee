# This module defines the routes loader for crush.  When called by the
# parent (crush/app), the module function gets the application routes
# and installs them.
#
_ = require 'underscore'
express = require 'express'
methods = require 'methods'


# This loader function gets the application routes and installs them,
# trapping and reporting any errors.
#
exports = module.exports = (options, callback)->
  try
    routes = options.module(options) or []
  catch err
    if options.module?
      console.status 'routes loader', error: err
    routes = []
  quiet = options.settings.routeloader?.quiet or false
  install options.app, routes, quiet
  callback null, 'routes installed'


# This function installs a sequence of routes onto the given application.
#
install = (app, routes, quiet)->
  # First we apply an order and a name to routes that do not have them:
  for idx in _.range(routes.length)
    routes[idx].order = idx if not routes[idx].order?
    routes[idx].name = "route.#{idx}" if not routes[idx].name?

  # Next we sort the routes by their order, and for each HTTP method
  # defined in the route, we set the route on the app:
  _.sortBy(routes, (route)->route.order).map (route)->

    console.status 'route',
      order: route.order
      name: route.name
      match: "#{route.match}"
      methods: methods.filter (method)-> route[method]
      quiet: quiet

    root = app.getroot()

    methods.map (method)->
      if route[method]?
        middlewares = route.middlewares or []
        app[method] route.match, middlewares, route[method]
        root.emit 'route.installed', route:route


  console.status 'router',
    installed: _.keys(routes).length
    quiet: quiet
