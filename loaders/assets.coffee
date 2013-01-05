

exports = module.exports = (options, callback)->
  name = options.app.get('name')
  assets[name] = {}
  callback null, 'assets installed'

exports.assets = assets = {}