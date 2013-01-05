#!/usr/bin/env coffee

# This module provides an interactive coffee shell with the specified project
# already loaded.
#
path = require 'path'
app = require '../app'
argv = require('optimist')(process.argv[6..])
  .usage('Usage: $0 --root=<project>')
  .demand(['root'])
  .argv


if not process.env.NODE_ENV?
  process.env.NODE_ENV = 'development'


root = path.resolve argv.root


app root, process.env.NODE_ENV, (err, app)->
  console.log 'Crush interactive shell ready'.blue.bold

  global.app = app
  global.settings = app.get 'settings'
  console.log 'Values added to the global namespace:'.blue.bold, 'app, settings'.white.bold

  add = ->
    modelnames = for name, model of app.get('models')
      global[name] = model
      name
    console.log 'Models added to the global namespace:'.blue.bold, (name.bold for name in modelnames).join(', ')
  setTimeout add, 2000

  console.log 'Press ^C to exit'.red
