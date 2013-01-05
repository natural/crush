# This module defines the middleware loader for crush.  When called by the
# parent (crush/app), the module function installs each middleware defined
# by the application.
#
# The application needs to specify a 'middleware.coffee' module in its
# directory.  That middleware module should export a module function, which
# should return a list of middleware objects and/or strings:
#
#   * when a string is given, it will be used to lookup a named middleware
#     (see crush/middlware.coffee)
#
#   * when an object is given, the object must specify 'name' and 'call'
#     keys to define the middleware
#


# This loader function is called by the parent (crush/app) for handling
# middleware module of an application.
#
exports = module.exports = (options, callback)->
  app = options.app
  defaults = app.get('crush').middleware
  quiet = options.settings.middlewareloader?.quiet or false

  try
    middlewares = options.module(options) or []
    middlewares = (registry.get mw, defaults for mw in middlewares)
  catch err
    middlewares = []
    if options.module?
      console.status 'middleware loader', error: err

  if not options.settings.middlewareloader?.norouter?
    middlewares.push call: app.router, name: 'router'

  if not options.settings.middlewareloader?.noerror?
    middlewares.push defaults.error

  appname = app.get('name').cyan
  middlewares.map (mw)->
    app.use mw.call
    console.status 'middleware',
      app: appname, name: mw.name.cyan, quiet: quiet

  console.status 'middleware', installed: middlewares.length, quiet: quiet
  callback null, 'middleware loaded'




# This function wraps the given hash with a 'get' function that retrieves
# middleware objects by key (a string) or by name (middleware.name).
#
newregistry = (registry)->
  all: registry
  get: (obj, defaults)->
    if typeof obj == 'string'
      registry[obj] = defaults[obj]
    else
      registry[obj.name] = obj


# This is our module-level middleware registry.
#
registry = newregistry {}
