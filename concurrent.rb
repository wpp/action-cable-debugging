require 'concurrent'
require 'byebug'

class Connection
  def initialize
    @socket = 'Socket'
    @ready_state = 'init'
  end

  def open(data)
    phlog("1", __method__, data)
    @ready_state = 'open'
  end

  def receive(data)
    if @ready_state != 'open'
      phlog("FAIL", __method__, data)
    else
      phlog("OK", __method__, data)
    end
  end

  def close(data)
    phlog("3", __method__, data)
    @ready_state = 'close'
  end

  def phlog(a, method, data)
    puts "#{a}: #{method} @ready_state: #{@ready_state}, #{Thread.current}, data: #{data}"
  end
end

class Server
  def initialize(max_size: 5)
    @executor = Concurrent::ThreadPoolExecutor.new(
      min_threads: 1,
      max_threads: max_size,
      max_queue: 0,
    )
  end

  def invoke(receiver, method, *args)
    @executor.post do
      receiver.send method, *args
    end
  end
end

tick = 0
server = Server.new
connection = Connection.new

#loop do
10.times do
  puts "tick: #{tick}"

  server.invoke(connection, :open, tick)
  server.invoke(connection, :receive, tick)
  server.invoke(connection, :close, tick)

  tick += 1
  puts
end
