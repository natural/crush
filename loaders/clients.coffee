# This module defines the super socket client loader for crush.  When called
# by the parent (crush/app), the module function loads the client definitions
# and starts them via the 'crush-socket-client' wrapper script.
#
_ = require 'underscore'
async = require 'async'
path = require 'path'
spawn = require('child_process').spawn


typemap =
  emitter: 'emitter'
  push: 'pull'
  pub: 'sub'


exports = module.exports = (options, callback)->
  if process.env.NOCLIENTS?
    callback null
    return

  if not options.module?
    callback null
    return

  clientcalls = for name, client of options.module(options) or {}
    do (name)->
      (cb)->
        server = options.app.get('servers')[name]
        if not server
          console.status 'super socket client', error: "no server named #{name}"
          cb null
          return

        params = _.defaults options or {},
          command: './crush-socket-client'
          cwd: path.resolve __dirname, '../bin'
          stdio: 'pipe'
          respawn: client.respawn
          name: name

        args = [
          '--module', options.modulename,
          '--port', server.port,
          '--type', typemap[server.type],
          '--name', name,
          ]

        # had a wierd scoping issue with this at the top-level
        run = ->
          child = spawn params.command, args,
            cwd: params.cwd
            stdio: params.stdio
            respawn: false

          if child.unref?
            child.unref()

          prefix = "#{name}:#{child.pid}"

          child.stdout.on 'data', (buf)->
            console.status prefix, "#{buf}"[0..-2]

          child.stderr.on 'data', (buf)->
            console.status prefix, stderr: "#{buf}"[0..-2]

          child.on 'exit', (code)->
            console.status prefix, exit: code, respawn: params.respawn
            if not code and params.respawn
              run()

          console.status 'super socket client'
            pid: child.pid
            port: server.port
            type: server.type
            name: name
            module: params.modulename

        run()
        cb null

  async.parallel clientcalls, callback
