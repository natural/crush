# This module defines the settings loader for crush.  When called by the
# parent (crush/app), the module function does nothing because the caller
# has already loaded and merged the settings object for the app.
#
exports = module.exports = (options, callback)->
  callback null, 'settings loader not implemented'

