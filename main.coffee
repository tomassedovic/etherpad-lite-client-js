http = require 'http'
https = require 'https'
url = require 'url'
querystring = require 'querystring'
_ = require 'underscore'
retriever = null


exports.connect = (options={}) ->
  unless 'apikey' of options
    throw new Error('You must specify etherpad-lite apikey')

  api = {}
  api.options = _.extend {}, options

  api.options.host ||= 'localhost'
  api.options.port ||= 9001

  retriever = http
  if api.options.port is 443
    retriever = https

  api.call = (functionName, functionArgs, callback) ->
    rootPath = api.options.rootPath or '/api/1.2.1/'
    apiOptions = _.extend { 'apikey': @options.apikey }, functionArgs
    httpOptions =
      host: @options.host
      port: @options.port
      path: rootPath + functionName + '?' + querystring.stringify apiOptions

    chunks = []
    req = retriever.get httpOptions, (res) ->
      res.on 'data', (data) ->
        chunks.push(data)
      res.on 'end', () ->
        try
          response = JSON.parse chunks.join('')
        catch error
          callback { code: -1, message: 'cannot parse the API response' }, null
          return

        if response.code is 0 and response.message is 'ok'
          callback null, response.data
        else
          callback { code: response.code, message: response.message}, null

    req.on 'error', (error) ->
      callback { code: -1, message: (error.message or error) }, null


  apiFunctions = [
    'createGroup'
    'createGroupIfNotExistsFor'
    'deleteGroup'
    'listPads'
    'createGroupPad'
    'listAllGroups'
    'createAuthor'
    'createAuthorIfNotExistsFor'
    'listPadsOfAuthor'
    'getAuthorName'
    'createSession'
    'deleteSession'
    'getSessionInfo'
    'listSessionsOfGroup'
    'listSessionsOfAuthor'
    'getText'
    'setText'
    'getHTML'
    'setHTML'
    'createPad'
    'getRevisionsCount'
    'padUsersCount'
    'padUsers'
    'deletePad'
    'getReadOnlyID'
    'setPublicStatus'
    'getPublicStatus'
    'setPassword'
    'isPasswordProtected'
    'listAuthorsOfPad'
    'getLastEdited'
    'sendClientsMessage'
    'listAllPads'
  ]

  for functionName in apiFunctions
    do (functionName) ->
      api[functionName] = (args, callback) ->
        if arguments.length is 1 and _.isFunction(args)
          callback = args
          args = {}

        callback = (->) unless callback?

        api.call(functionName, args, callback)
        return null


  return api
