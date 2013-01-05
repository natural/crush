# This is the package module for crush/loaders.  It exports 'names', which
# is a list names of available loaders. For each name in that list, it also
# exports that loader.
#


# This list of names drives two things:
#
#   * the name of the loader module to import from this directory, i.e.,
#     ./loaders/settings.coffee, ./loaders/models.coffee, etc.
#
#   * the name of the module to load from each app directory, e.g.,
#     todo-app/settings.coffee, todo-app/models.coffee, etc.
#
exports.names = [
  'settings'
  'servers'
  'middleware'
  'plugins'
  'models'
  'routes'
  'clients'
  'assets'
  ]


# This installs each named loader.
#
exports.names.map (name)->
  exports[name] = require "./#{name}"
