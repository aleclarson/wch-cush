path = require 'path'
wch = require 'wch'

emitBadImports = (err) ->
  files = {}

  err.imports.forEach (dep) ->
    events = files[dep.parent] or= []
    events.push
      file: path.join(err.root, dep.parent)
      line: dep.line - 1
      message: "Cannot find module: '#{dep.ref}'"
    return

  for file of files
    wch.emit 'file:error', files[file]
  return

module.exports = (log) ->
  cdn = require('cush-cdn')()
  cdn.on 'error', (err) ->
    if err.code is 'BAD_IMPORTS'
      return emitBadImports err
    log.error err

  attach: (pack) ->
    cdn.loadProject pack.path

  detach: (pack) ->
    cdn.dropProject pack.path

  stop: -> cdn.close()
