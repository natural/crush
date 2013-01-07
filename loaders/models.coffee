# This module defines the models loader for crush.  When called by the
# parent (crush/app), the module function establishes database connections
# for each database defined in the settings
#
# It's worth noting here that the models defined by apps in their
# 'models.coffee' module (or 'models' package) do not need to be the
# same models as served to the client, nor do they need to be served to
# the client at all.
#
# Also, every app shares the same 'models' object.  That's not cool, but
# it works.
#
_ = require 'underscore'
async = require 'async'
mongoose = require 'mongoose'
mongoose_extend = require 'mongoose-schema-extend'


# This loader function is called by the parent (crush/app) for configuring
# and installing the application models.
#
exports = module.exports = (options, callback)->
  app = options.app
  app.set 'models', models
  app.set 'connections', connections

  databases = options.settings.databases or {}
  quiet = options.settings.modelloader?.quiet or false

  try
    schemas = options.module(options) or []
  catch err
    if options.module?
      console.status 'model loader', error: err
      throw err
    schemas = []

  connectcalls = for schemadef in schemas
    do (schemadef)->
      (cb)->
        name = schemadef.name
        db = connection name.toLowerCase(), databases

        schema = makeSchema db, schemadef
        schema.app = app
        meta = schema.statics.meta

        db.on 'connected', ->
          model = db.model name, schema, meta.collection
          models[name] = schema.instance = model

          console.status 'schema',
            name: name.red
            app: options.settings.app.name
            collection: meta.collection

        cb()

  async.parallel connectcalls, callback


# This is our module-level model registry.
#
exports.models = models = {}

# This is our module-level connections registry.
#
exports.connections = connections = {}



# Hash of existing functions and a getter for them.  We need this because
# mongoose requires related models to use the same connection.  Note that
# settings can reuse a connection by name, e.g.,
#
# exports.production =
#   databases:
#     first:
#       mongo: 'mongodb://...'
#     second:
#       reuse: 'first'

connection = (name, dbs)->
  params = dbs[name]
  if name of connections
    connections[name]
  else if params.reuse
    connection params.reuse, dbs
  else
    connections[name] = mongoose.createConnection params.mongo
    connections[name]




_cache = {}


exports.makeSchema = makeSchema = (db, options)->
  options = _.defaults options,
    discriminatorKey: undefined
    strict: true
    versionKey: false

  if options.parent?
    parent = _cache[options.parent]
    schema = parent.extend options.attributes
    collection = parent.statics.meta.collection
  else

    collection = options.collection
    schema = new mongoose.Schema options.attributes,
      strict: options.strict
      collection: collection
      versionKey: options.versionKey
      discriminatorKey: options.discriminatorKey
    _cache[options.name] = schema

  schema.statics.meta =
    name: options.name
    collection: collection

  for key, value of options.statics or {}
    schema.statics[key] = value

  for key, value of options.methods or {}
    schema.methods[key] = value

  for plugin in options.plugins or []
    schema.plugin plugin

  if options.indexes?.length
    for [keys, conf] in options.indexes or []
      # move index construction
      console.status 'schema index', model:options.name, keys:keys, options:conf
      schema.index keys, conf

  schema
