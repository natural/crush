url = require 'url'
mongoose = require 'mongoose'


exports.chain = chain = (fn...)->
  (v)->
    for f in fn
      if not f(v)
        return false
    true


exports.minlen = minlen = (len)->
  (v)->
    (v or '').length >= len


exports.maxlen = maxlen = (len)->
  (v)->
    (v or '').length < len


exports.name = chain minlen(1), maxlen(256)
exports.desc = chain minlen(0), maxlen(1024)


exports.http_url = (v)->
  if not v # allow null... better way?
    return true
  try
    v = url.parse v
  catch err
    return false
  v.protocol in ['http:', 'https:']

exports.image_url = (v)->
  if not v # allow null... better way?
    return true
  try
    v = url.parse v
  catch err
    return false
  /\.jpg$|\.png$/i.test v.pathname


exports.oid = (v)->
  if v?.toHexString
    return true
  try
    mongoose.mongo.ObjectID v
    true
  catch err
    false
