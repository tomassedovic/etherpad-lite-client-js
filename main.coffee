http = require 'http'
https = require 'https'
url = require 'url'
querystring = require 'querystring'
retriever = null


exports.connect = (options={}) ->
  unless 'apikey' of options
    throw new Error('You must specify etherpad-lite apikey')

  api = {}
  api.options = Object.assign {}, options

  api.options.host ||= 'localhost'
  api.options.port ||= 9001

  retriever = http
  if api.options.port is 443 or api.options.ssl
    retriever = https

  api.call = (functionName, functionArgs, callback) ->
    rootPath = api.options.rootPath or '/api/1.2.15/'
    apiOptions = Object.assign { 'apikey': @options.apikey }, functionArgs
    httpOptions = Object.assign @options, {path: rootPath + functionName + '?' + querystring.stringify apiOptions}

    chunks = []
    req = retriever.get httpOptions, (res) ->
      res.on 'data', (data) ->
        chunks.push(data)
      res.on 'end', () ->
        try
          data = chunks.join('');
          if Buffer.isBuffer(data)
            data = data.toString();
            response = JSON.parse(data);
          response = JSON.parse chunks.join('')
        catch error
          callback { code: -1, message: 'cannot parse the API response' }, null
          return

        if response.code is 0 and response.message is 'ok'
            if response.data
                callback null, response.data
            else
                callback null, response
        else
          callback { code: response.code, message: response.message}, null

    req.on 'error', (error) ->
      callback { code: -1, message: (error.message or error) }, null


  # https://raw.githubusercontent.com/ether/etherpad-lite/develop/src/node/handler/APIHandler.js
  apiFunctions = [
    'createGroup'
    'createGroupIfNotExistsFor'
    'deleteGroup'
    'listPads'
    'listAllPads'
    'createDiffHTML'
    'createPad'
    'createGroupPad'
    'createAuthor'
    'createAuthorIfNotExistsFor'
    'listPadsOfAuthor'
    'createSession'
    'deleteSession'
    'getSessionInfo'
    'listSessionsOfGroup'
    'listSessionsOfAuthor'
    'getText'
    'setText'
    'getHTML'
    'setHTML'
    'getAttributePool'
    'getRevisionsCount'
    'getSavedRevisionsCount'
    'listSavedRevisions'
    'saveRevision'
    'getRevisionChangeset'
    'getLastEdited'
    'deletePad'
    'copyPad'
    'movePad'
    'getReadOnlyID'
    'getPadID'
    'setPublicStatus'
    'getPublicStatus'
    'setPassword'
    'isPasswordProtected'
    'listAuthorsOfPad'
    'padUsersCount'
    'getAuthorName'
    'padUsers'
    'sendClientsMessage'
    'listAllGroups'
    'checkToken'
    'appendChatMessage'
    'getChatHistory'
    'getChatHistory'
    'getChatHead'
    'restoreRevision'
    'appendText'
    'getStats'
    'copyPadWithoutHistory'
  ]

  for functionName in apiFunctions
    do (functionName) ->
      api[functionName] = (args, callback) ->
        if arguments.length is 1 and typeof args == 'function'
          callback = args
          args = {}

        callback = (->) unless callback?

        api.call(functionName, args, callback)
        return null


  return api
