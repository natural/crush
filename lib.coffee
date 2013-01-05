# This library module extends various globals.  It needs to be imported once
# in the project, and it defines a single export, 'classname'.
#
_ = require 'underscore'
require 'colors'
util = require 'util'


# This adds a 'plural' method to all strings.  Pass in a list value,
# the singular suffix, and the plural suffix.
#
String.prototype.plural = (v, s, p)->
  if not s?
    s = ''
  if not p?
    p = 's'
  if v?.length==1
    "#{@}#{s}"
  else
    "#{@}#{p}"


# This adds the function 'console.inspect' for easier printing of complex
# objects.
#
console.inspect = (obj, hidden=false, depth=2, colors=true)->
  console.log util.inspect(obj, hidden, depth, colors)


# This adds the function 'console.status' for common printing of status
# messages with keyword arguments (objects).
#
console.status = (section, options)->
  quiet = false
  options = options or {}
  if options.error
    args = ["[#{section}] error".red, options.error]
  else
    if _.isString options
      kv = [options]
    else
      if options.quiet?
        quiet = options.quiet
      delete options.quiet
      kv = for key, val of options
        if _.isString val
          val = "#{val}"
        else if _.isArray val
          val = util.inspect val, false, 2, true
        else
          val = util.inspect val, true, 2, true
        key = "#{key}"
        "#{key}: #{val.bold}"
    args = ["[#{section}]".grey.bold, kv.join(', ')]
  if not quiet
    console.log.apply @, args


if process.env.NODE_ENV == 'test'
  console.status = ->


exports.classname = (obj)->
  if obj and obj.constructor and obj.constructor.toString
    arr = obj.constructor.toString().match /function\s*(\w+)/
    if arr?.length == 2
      arr[1]
