# This module defines the plugins loader for crush.  When called by the
# parent (crush/app), the module function does nothing.
#
exports = module.exports = (options, callback)->

  try
    plugins = options.module() or []
  catch err
    if options.module?
      console.status 'plugins loader', error: err
    plugins = {}

  options.app.locals plugins
  console.status 'plugins loader', loaded: plugins?
  callback null, 'plugins loaded'
