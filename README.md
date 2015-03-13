#  [![Build Status](https://secure.travis-ci.org//cw-spider.png?branch=master)](http://travis-ci.org//cw-spider)

> The best module ever.


## Getting Started

Install the module with: `npm install cw-spider`

```js

{Spider} = require 'cw-spider'


class XiaMiArtlistSpider extends Spider
  mapUrl: (id)->
    "http://www.xiami.com/artist/#{id}"

  parse: (id, $,result)->
    name = $('div#title>h1').contents().first().text()
    avatar = $('a#cover_lightbox>img').attr('src')
    console.log "id:#{id},name:#{name},photo:#{avatar}"

    {id: id, name: name}

  save: (data)->
    console.log data

spider = new XiaMiArtlistSpider()
spider.start [1...10000]

```

## Documentation

运行环境
iojs 1.5.0
coffee 1.9.1

###构造函数默认参数
```
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

co: co-limiter的配置
rate:request-rate-limiter配置，请参考https://www.npmjs.com/package/request-rate-limiter
request:request配置，请参考：

```


## Examples

_(Coming soon)_


## Contributing

In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com).


## License

Copyright (c) 2015   
Licensed under the MIT license.
