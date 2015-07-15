# https://github.com/Joe-noh/sinatra-faye-websocket-example
require 'bundler'
Bundler.require

require 'json'
require 'work_queue'

Faye::WebSocket.load_adapter('thin')

class A
  class << self
    def callback(socket, id)
      -> { socket.send random_sleep_msg(id) }
    end

    def random_sleep_msg(id)
      start = Time.now
      sleep rand(0.42...5.42)
      time = Time.now - start
      {request_order: id, type: 'expensive task', time: time}.to_json
    end
  end
end

get '/' do
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)

    ws.on(:open) do |event|
      puts 'On Open'
    end

    ws.on(:message) do |msg|
      data = msg.data
      if data.strip == 'close'
        ws.send('client requested the connection be closed. Closing.')
        ws.close
      else
        resp = {
          type: 'user input',
          original: data,
          reverse: data.reverse
        }
        ws.send(resp.to_json)
      end
    end

    ws.on(:close) do |event|
      puts 'On Close'
    end

    # return async rack response: [ -1, {}, [] ]
    ws.rack_response

    # run async process (simulating expensive/external work)
    max_threads = 10
    max_tasks = nil
    work_queue = WorkQueue.new(max_threads, max_tasks)
    (1..10).each_with_index do |i|
      cb = A.callback(ws, i)
      work_queue.enqueue_b(&cb)
    end

    # wait until the queue is empty...
    work_queue.join

    # the queue may be empty but I think we need to wait just a second to allow
    # the data to be sent over the wire before closing the connection
    sleep 1

    ws.close
  else
    body = {
      error: 'Not Acceptable',
      message: 'Client does not support websockets'
    }
    [406, { 'Content-Type' => 'text/json' }, [body.to_json]]
  end
end
