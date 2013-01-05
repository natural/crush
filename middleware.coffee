# This module defines various middlewares and middleware factories.  The
# parent (./app) installes these callables as app.get('crush').middleware.
#
assetscall = require 'connect-assets'
express = require 'express'



exports.bodyParser =
  name: 'body-parser'
  call: express.bodyParser()


exports.error =
  name: 'error-handler'
  local: null
  call: (err, req, res, next)->
    if exports.error.local
      exports.error.local err, req, res, next
    else
      console.error err
      res.send(500, {error: "#{err}"})


exports.favicon =
  name: 'favicon'
  call: express.favicon()


exports.logger =
  name: 'logger'
  call: express.logger 'dev'



exports.makeAssetsHandler = (options)->
  name: 'dynamic-assets'
  call: assetscall
    src: options.dir
    build: options.build
    buildDir: options.buildDir or './asset-cache/'
    helperContext: options.helperContext or global


exports.makeAuthRequired = (login)->
  name: 'auth-required'
  call: (req, res, next)->
    if req.isAuthenticated()
      next()
    else
      res.redirect "#{login}?#{req.originalUrl}"


exports.makeCookieParser = (secret)->
  name: 'cookie-parser'
  call: express.cookieParser secret


exports.makeSession = (secret, store)->
  name: 'session'
  call: express.session
    secret: secret
    store: store


exports.makeStaticHandler = (options)->
  name: 'static-files'
  call: express.static options.dir


exports.makeLogger = (env)->
  switch env
    when 'development' then format = 'dev'
    when 'production' then format = 'short'
    when 'test' then format = ->
    else format = 'default'

  name: 'logger'
  call: express.logger format
