# This module defines the super socket server loader for crush.  When called
# by the parent (crush/app), the module function loads the server definitions
# and starts them.
#
ss = require 'super-sockets'


exports = module.exports = (options, callback)->
  if process.env.NOSERVERS?
    callback()
    return

  options.app.set 'servers', registry

  try
    servers = options.module(options) or []
  catch err
    if options.module?
      console.status 'socket server loader', error: err
    servers = []

  for defn in servers
    do (defn)->
      name = defn.name
      if name and not registry[name]
        port = if defn.port? then defn.port else portcounter++
        type = if defn.type? then defn.type else 'emitter'
        sock = ss.socket type
        sock.bind port

        registry[name] =
          name: name
          port: port
          type: type
          emit: (event, value)->
            sock.emit event, value
          send: (value)->
            sock.send value

        console.status 'super socket server'
          name: name
          port: port
          type: type

  callback()


registry = {}
portcounter = 5000
