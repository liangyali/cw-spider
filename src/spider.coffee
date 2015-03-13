events = require 'events'
co = require 'co'
RequestRateLimiter = require 'request-rate-limiter'
cheerio = require 'cheerio'
debug = require('debug') 'cw:spider'
HashRing = require 'hashring'
limiter = require 'co-limiter'
_ = require 'lodash'

#=====================================
# 404 error
#=====================================
class StatusCodeError extends Error
  constructor: (@params, @statusCode)->
    super "id=#{@params}, statusCode=#{@statusCode}"

#=====================================
# response body empty error
#=====================================
class BodyEmptyError extends Error
  constructor: (@params)->
    super "id=#{@params}, result.body is null"

#=====================================
# not implemented error
#=====================================
class NotImplemented extends Error
  constructor: (@methodName)->
    super "[#{methodName}] not implemented"

#=====================================
# spider
#=====================================
class Spider extends events.EventEmitter
  constructor: (@options)->
    @._initialize(@options)
    super

  _initialize: (@options)->
    options =
      co:
        limt: 2
      rate:
        rate: 60
        interval: 30
        backoffCode: 429
        backoffTime: 10
        maxWaitingTime: 300
      request:
        timeout: 5000
        maxSockets: 1

    @options = _.merge options, @options
    @requestRateLimiter = new RequestRateLimiter(@options.rate)
    @ring = new HashRing
    @limit = limiter @options.co.limt

  #映射Id到Url
  mapUrl: (params)->
    throw new NotImplemented 'mapUrl'

  addProxy: (server)->
    debug "[addProxy,server:#{server}]"
    @ring.add server

  removeProxy: (server)->
    debug "[removeProxy,server:#{server}]"
    @ring.remove server

  _getProxy: (key)->
    @ring.get key

  #parse the dom to data
  parse: (i, $)->
    throw new NotImplemented 'perform'

  #save the parsed data
  save: (data)->
    throw new NotImplemented 'save'

  #爬虫的任务
  _task: (params)->
    #map spider url
    url = this.mapUrl(params)
    debug "[FetchUrl:#{url}]"

    #get proxy address
    proxy = @._getProxy url
    debug "[GetProxyAddress:#{proxy}]"

    options = _.merge {url: url, proxy: proxy}, @options.request

    #resust target url
    result = yield @requestRateLimiter.request options
    debug "[HTTPResponse](#{params}) statusCode", result.statusCode
    debug "[HTTPResponse](#{params}) body.length", result.body?.length

    #check result
    throw new StatusCodeError(params, result?.statusCode) if result.statusCode != 200
    throw new BodyEmptyError(params) if not result.body

    #perform parsed result
    $ = cheerio.load result.body
    data = @.parse params, $, result

    #save data
    @.save data

  start: (paramsList) ->
    for params in paramsList
      co ()=>
        yield @limit @._task(params)
      .catch (error)=>
        debug "[Error:#{error.stack}]"
        @.emit 'error', error

module.exports = {
  StatusCodeError,
  BodyEmptyError,
  NotImplemented,
  Spider
}