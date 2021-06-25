// Generated by CoffeeScript 1.10.0
(function() {
  var _, http, https, querystring, retriever, url;

  http = require('http');

  https = require('https');

  url = require('url');

  querystring = require('querystring');

  _ = require('underscore');

  retriever = null;

  exports.connect = function(options) {
    var api, apiFunctions, base, base1, fn, functionName, i, len;
    if (options == null) {
      options = {};
    }
    if (!('apikey' in options)) {
      throw new Error('You must specify etherpad-lite apikey');
    }
    api = {};
    api.options = _.extend({}, options);
    (base = api.options).host || (base.host = 'localhost');
    (base1 = api.options).port || (base1.port = 9001);
    retriever = http;
    if (api.options.port === 443 || api.options.ssl) {
      retriever = https;
    }
    api.call = function(functionName, functionArgs, callback) {
      var apiOptions, chunks, httpOptions, req, rootPath;
      rootPath = api.options.rootPath || '/api/1.2.12/';
      apiOptions = _.extend({
        'apikey': this.options.apikey
      }, functionArgs);
      httpOptions = _.extend(this.options, {
        path: rootPath + functionName + '?' + querystring.stringify(apiOptions)
      });
      chunks = [];
      req = retriever.get(httpOptions, function(res) {
        res.on('data', function(data) {
          return chunks.push(data);
        });
        return res.on('end', function() {
          var error, error1, response;
          try {
            var data = chunks.join();
            if (Buffer.isBuffer(data)) {
              data = data.toString();
            }
            response = JSON.parse(data);
          } catch (error1) {
            error = error1;
            callback({
              code: -1,
              message: 'cannot parse the API response'
            }, null);
            return;
          }
          if (response.code === 0 && response.message === 'ok') {
            if (response.data) {
              return callback(null, response.data);
            } else {
              return callback(null, response);
            }
          } else {
            return callback({
              code: response.code,
              message: response.message
            }, null);
          }
        });
      });
      return req.on('error', function(error) {
        return callback({
          code: -1,
          message: error.message || error
        }, null);
      });
    };
    apiFunctions = ['createGroup', 'createGroupIfNotExistsFor', 'deleteGroup', 'listPads', 'listAllPads', 'createDiffHTML', 'createPad', 'createGroupPad', 'createAuthor', 'createAuthorIfNotExistsFor', 'listPadsOfAuthor', 'createSession', 'deleteSession', 'getSessionInfo', 'listSessionsOfGroup', 'listSessionsOfAuthor', 'getText', 'setText', 'getHTML', 'setHTML', 'getAttributePool', 'getRevisionsCount', 'getSavedRevisionsCount', 'listSavedRevisions', 'saveRevision', 'getRevisionChangeset', 'getLastEdited', 'deletePad', 'copyPad', 'movePad', 'getReadOnlyID', 'getPadID', 'setPublicStatus', 'getPublicStatus', 'setPassword', 'isPasswordProtected', 'listAuthorsOfPad', 'padUsersCount', 'getAuthorName', 'padUsers', 'sendClientsMessage', 'listAllGroups', 'checkToken', 'appendChatMessage', 'getChatHistory', 'getChatHistory', 'getChatHead', 'restoreRevision'];
    fn = function(functionName) {
      return api[functionName] = function(args, callback) {
        if (arguments.length === 1 && _.isFunction(args)) {
          callback = args;
          args = {};
        }
        if (callback == null) {
          callback = (function() {});
        }
        api.call(functionName, args, callback);
        return null;
      };
    };
    for (i = 0, len = apiFunctions.length; i < len; i++) {
      functionName = apiFunctions[i];
      fn(functionName);
    }
    return api;
  };

}).call(this);
