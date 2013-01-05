# This is the main crush application module.  Clients can call this module
# to construct a new crush application from a directory.
#
_ = require 'underscore'
async = require 'async'
express = require 'express'

db = require './db'
lib = require './lib'
loaders = require './loaders'
middleware = require './middleware'
session = require './session'


# The callable module export, aka 'make'.  This function recursively constructs
# an application from a directory.
#
# If the 'settings' module within the specified directory contains an
# 'apps' list, the values from that list are used to construct mounted
# applications.
#
#   * 'dir' is the name of the root application directory; it should
#     contain a 'settings' module.
#
#   * 'env' is the name of the environment ('development', 'production').
#
#   * 'callback' is a function invoked with the newly constructed (but
#     not started) application
#
exports = module.exports = make = (dir, env, callback)->
  try
    settings = require "#{dir}/settings"
  catch err
    settings = null

  settings = settingsfactory env, settings
  app = expressfactory dir, settings

  console.status 'app', name: app.get('name'), status: 'loading'
  options = env: env, app: app, settings: settings

  load dir, options, (err, results)->
    submakes = for decl in settings.apps or []
      do (decl)->
        (callback)->
          make decl.dir, env, (err, subapp)->
            app.use decl.mount, subapp
            callback err, null

    async.parallel submakes, (err, results)->
      if err
        console.status 'make', error: err
      callback err, app


# The 'load' function brings in the various parts of an application.
#
# The loaded values are passed to the various 'loader' callables.  The loader
# callables in turn act upon the values to initialize and integrate them
# with the application.
#
load = (dir, options, callback)->
  loadercalls = for part in loaders.names
    do (part)->
      (cb)->
        opts = _.extend {}, options
        try
          opts.modulename = "#{dir}/#{part}"
          opts.module = require opts.modulename
        catch err
          if err.message?[0..17] != 'Cannot find module'
            console.status "#{part} loader", error: err

        # never signal an error in the callback so
        # that the async.parallel call does not stop
        loaders[part] opts, (err, results)->
          cb null, results

  async.parallel loadercalls, (err, results)->
    callback err, results


# The 'expressfactory' function creates a new instance of express and
# configures it with the given settings.
#
expressfactory = (dir, settings)->
  exp = express()
  exp.set 'name', settings.app?.name or dir
  exp.set 'views', settings.views?.dir or "#{dir}/views"
  exp.set 'view engine', settings.views?.engine or 'jade'
  exp.set 'crush',
    db: db
    middleware: middleware
    session: session

  if settings
    exp.set 'settings', settings

  exp.getroot = ->
    if @parent
      @parent.getroot()
    else
      @

  exp


# The 'settingsfactory' function merges the 'env' section from the given
# settings objects with the 'shared' section, returning a new object with
# the merged values.
#
settingsfactory = (env, sources...)->
  target = {}
  for source in sources
    _.extend target, (_.extend {}, (source?.shared or {}), (source?[env] or {}))
  return target
