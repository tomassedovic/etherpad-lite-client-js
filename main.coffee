http = require 'http'
url = require 'url'
u_ = require 'underscore'


exports.connect = (options={}) ->
  return unless 'apikey' of options

  api = {}
  api.options = u_.extend {}, options

  api.options.host ||= 'localhost'
  api.options.port ||= 9001


  api.call = (functionName, functionArgs, callback) ->
    if arguments.length is 2 and u_.isFunction(functionArgs)
      callback = functionArgs
      functionArgs = {}

    rootPath = '/api/1/'
    apiOptions = u_.extend { 'apikey': @options.apikey }, functionArgs
    httpOptions =
      host: @options.host
      port: @options.port
      path: rootPath + functionName + '?' + querystring.stringify apiOptions

    chunks = []
    req = http.get httpOptions, (res) ->
      res.on 'data', (data) ->
        chunks.push(data)
      res.on 'end', () ->
        try
          response = JSON.parse chunks.join('')
        catch
          callback { code: -1, message: 'cannot parse the API response' }, null
          return

        if response.code is 0 and response.message is 'ok'
          callback null, response.data
        else
          callback { code: response.code, message: response.message}, null

    req.on 'error', (error) ->
      callback { code: -1, message: (error.message or error) }, null


  apiFunctions = [
    'createGroup',
    'createGroupIfNotExistsFor',
    'deleteGroup',
    'listPads',
    'createGroupPad',
    'createAuthor',
    'createAuthorIfNotExistsFor',
    'createSession',
    'deleteSession',
    'getSessionInfo',
    'listSessionsOfGroup',
    'listSessionsOfAuthor',
    'getText',
    'setText',
    'createPad',
    'getRevisionsCount',
    'deletePad',
    'getReadOnlyID',
    'setPublicStatus',
    'getPublicStatus',
    'setPassword',
    'isPasswordProtected',
  ]
  for functionName in apiFunctions
    api[functionName] = (args, callback) ->
      api.call(functionName, args, callback)


  return api
