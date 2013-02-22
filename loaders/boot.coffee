# This module defines the boot loader for crush.  When called by the parent
# (crush/app), the module function loads the project boot file, if any.
#
exports = module.exports = (options, callback)->

  try
    status = options.module(options)
    console.status 'boot loader', success: status
  catch err
    if options.module?
      console.status 'boot loader', error: err

  callback null, 'boot'
