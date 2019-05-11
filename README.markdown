Etherpad Lite API
=================

Supports all the API calls described in the [Etherpad Lite API page][1].


Setup
-----

You can install it via NPM:
```
$ npm install etherpad-lite-client
```
or add it to your `package.json` dependencies:
```json
"etherpad-lite-client": "0.7.x"
```

Usage
-----
```javascript
api = require('etherpad-lite-client')
etherpad = api.connect({
  apikey: 'UcCGa6fPpkLflvPVBysOKs9eeuWV08Ul',
  host: 'localhost',
  port: 9001,
})

etherpad.createGroup(function(error, data) {
  if(error) console.error('Error creating group: ' + error.message)
  else console.log('New group created: ' + data.groupID)
})
```

Certain API calls require that you pass some arguments:

```javascript
var args = {
  groupID: 'g.yJPG7ywIW6zPEQla',
  padName: 'testpad',
  text: 'Hello world!',
}
etherpad.createGroupPad(args, function(error, data) {
  if(error) console.error('Error creating pad: ' + error.message)
  else console.log('New pad created: ' + data.padID)
})
```

Any `options` passed to `api.connect` will be passed to `http(s).request` as `options` so you can specify any `.request` options. All `options` are described https://nodejs.org/api/https.html#https_https_request_options_callback

For example, if you have Etherpad configured locally, running SSL on 9001 with self signed certificates, you can configure client as follows:

```javascript
etherpad = api.connect({
  apikey: 'UcCGa6fPpkLflvPVBysOKs9eeuWV08Ul',
  host: 'localhost',
  port: 9001,
  ssl: true,
  rejectUnauthorized: false
})
```

Where `ssl` switches EP client to HTTPS client and `rejectUnauthorized: false` disables CA certificate check. For more options see https://nodejs.org/api/https.html#https_https_request_options_callback.

### Callback & Returned Data ###

The callback function should look like this:
```javascript
function(error, data) {
  if(error) {
    // handle error using error.code and error.message
  }

  // some code
}
```
The callback function takes two argument: `error` and `data`.

#### error ###
`error` is null if everything is fine. Otherwise it's a JavaScript object that
describes what's wrong.

It has two attributes: `code` and `message`:
* `error.code`
  * `1` wrong parameters
  * `2` internal error
  * `3` no such function
  * `4` no or wrong API Key
  * `-1` there was problem with calling Etherpad API
* `error.message`: a text representation of the error

#### data ####

`data` is a JavaScript object from the Etherpad response or `null` (on error).

#### Development ####

The author prefers pull requests for changes. To do this, first fork the repository, then checkout your fork and apply your changes. Then create your pull request.
Please create one pull request per change.

Do not change main.js but instead only main.coffee, use "npm i coffeescript@1.10.0 -g" in order to prevent too many unwanted and untested changes.
After you made your changes to main.coffee in your fork, on linux run "cake build" in the root of your project, it will generate a new main.js file.
On windows you can compile by issuing "coffee --compile main.coffee" command.


License
-------

This code is released under the MIT (Expat) license.

See the attached file LICENSE.txt for more details or visit:

<http://www.opensource.org/licenses/MIT>


[1]: https://github.com/ether/etherpad-lite/wiki/HTTP-API
