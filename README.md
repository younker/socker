### Sinatra/Express Over WebSockets

Proof-of-concept to get an Express app talking to a Sinatra server over websockets.

The Sinatra app uses [Faye::WebSocket](https://github.com/faye/faye-websocket-ruby) for
websocket connections and [WorkQueue](https://github.com/fmmfonseca/work_queue) to
manage async tasks meant to mimic expensive, most likely external dependency based, work.

### Setup

```bash
bundle install
bundle exec ruby sinatra.rb -p 3009
node express.js
open http://localhost:3010
```

### Example:

#### Terminal
```
--- projects/socker ‹master* AM› » bundle exec ruby sinatra.rb -p 3009 &
[1] 17421
--- projects/socker ‹master* AM› » == Sinatra (v1.4.6) has taken the stage on 3009 for development with backup from Thin
Thin web server (v1.6.3 codename Protein Powder)
Maximum connections set to 1024
Listening on localhost:3009, CTRL+C to stop

--- projects/socker ‹master* AM› » node express.js &
[2] 17502
--- projects/socker ‹master* AM› » listening on *:3010
On Open
On Close
127.0.0.1 - - [15/Jul/2015:13:31:21 -0700] "GET / HTTP/1.1" 200 - 9.7507
```

##### In the Browser

```
socket.onopen
socket.onmessage: {"request_order":8,"type":"expensive task","time":1.497132}
socket.onmessage: {"request_order":6,"type":"expensive task","time":1.737888}
socket.onmessage: {"request_order":7,"type":"expensive task","time":2.412229}
socket.onmessage: {"type":"user input","original":"foo","reverse":"oof"}
socket.onmessage: {"request_order":9,"type":"expensive task","time":3.928517}
socket.onmessage: {"request_order":2,"type":"expensive task","time":4.373352}
socket.onmessage: {"request_order":4,"type":"expensive task","time":4.379662}
socket.onmessage: {"request_order":3,"type":"expensive task","time":4.529665}
socket.onmessage: {"request_order":10,"type":"expensive task","time":4.540885}
socket.onmessage: {"request_order":1,"type":"expensive task","time":4.964676}
socket.onmessage: {"request_order":5,"type":"expensive task","time":5.381453}
socket.onclose
```
