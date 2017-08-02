# README

## Setup:

### commands

```bash
rails s -p 3001
ruby client.rb
rails runner broadcast.rb
```

### Cable.yml

Connecting to a redis container running locally on 6381

```yaml
development:
  adapter: redis
  url: redis://localhost:6381
  channel_prefix: testing_chat
```

### Action Cable Client

Have one action cable client (`client.rb`) running.

1. This client connects to the action cable server and
2. subscribes to the `ChatChannel`.
3. When the client receives a message from that channel it will disconnect and
   start the process from 1.

### Broadcast source

Have a broadcast source running (Also tested multiple runners (3)).

In `broadcast.rb` we broadcast 100 000 messages to the cable client. After
sending a message we sleep for 0.1 seconds.

## Observerations

At a certain point the client connects, but doesn't receive the subcription
confirmation and therefore misses broadcast messages.

**`client.rb`:**

```log
...
3593 Client connected
3593 Client subscribed
3593 Client received: {"identifier"=>"{\"channel\":\"ChatChannel\"}", "message"=>{"type"=>"test", "content"=>"92407 17284"}}
3593 Client disconnected

3594 Client connected
3594 Client subscribed
3594 Client received: {"identifier"=>"{\"channel\":\"ChatChannel\"}", "message"=>{"type"=>"test", "content"=>"92407 17285"}}
3594 Client disconnected

*ERROR*
3595 Client connected
```

**rails server:**

```log
Started GET "/cable" for ::1 at 2017-08-01 12:40:53 +0200
Started GET "/cable/" [WebSocket] for ::1 at 2017-08-01 12:40:53 +0200
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
Connection.connect
Subscribed
ChatChannel is transmitting the subscription confirmation
ChatChannel is streaming from channel_1
ChatChannel transmitting {"type"=>"test", "content"=>"92407 17285"} (via streamed from channel_1)
Finished "/cable/" [WebSocket] for ::1 at 2017-08-01 12:40:53 +0200
Unsubscribed
ChatChannel stopped streaming from channel_1
Connection.disconnect

*ERROR*
Started GET "/cable" for ::1 at 2017-08-01 12:40:53 +0200
Started GET "/cable/" [WebSocket] for ::1 at 2017-08-01 12:40:53 +0200
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
Connection.connect
```

### Run log

1. failure at message #2000  (3 broadcast runners)
2. no failure (10000 msgs)   (3 broadcast runners)
3. failure at message #3595  (3 broadcast runners)
4. failure at message #2367  (1 broadcast runner)
5. failure at message #6285  (1 broadcast runner)
6. failure at message #6147  (1 broadcast runner)

maclover patch:
1. no failure (10000 msgs)   (1 broadcast runner)
2. failure at message #9784  (1 broadcast runner)
3. failure at message #2506  (1 broadcast runner)
4. no failure (100000 msgs)  (1 broadcast runner)
5. failure at message #1504  (1 broadcast runner)
6. failure at message #83132 (1 broadcast runner)

wpp patch:
1. no failure (100000 msgs)  (3 broadcast runners)
2. no failure (100000 msgs)  (4 broadcast runners)

#### Notes

```log
Connection.connect
subscriptions: []
PHIL: ApplicationCable::Connection on_message
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
PHIL: ActionCable::Connection::MessageBuffer receive
connection#receive: {"command":"subscribe","identifier":"{\"channel\":\"ChatChannel\"}"}
dispatch_websocket_message: {"command":"subscribe","identifier":"{\"channel\":\"ChatChannel\"}"}
Subscriptoins execute_command: subscribe
Subscriptoins add: 1
PHIL: subscribed: [:subscribe, :unsubscribe]
Subscribed
ChatChannel is transmitting the subscription confirmation
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221427"} (via streamed from channel_1)
ChatChannel is streaming from channel_1
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221428"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221429"} (via streamed from channel_1)
Finished "/cable/" [WebSocket] for ::1 at 2017-08-02 12:03:37 +0200
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221430"} (via streamed from channel_1)
Started GET "/cable" for ::1 at 2017-08-02 12:03:37 +0200
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221431"} (via streamed from channel_1)
PHIL: unsubscribed
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221432"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221433"} (via streamed from channel_1)
PHIL: ActionCable::Server::Base call
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221434"} (via streamed from channel_1)
Unsubscribed
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221435"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221436"} (via streamed from channel_1)
Started GET "/cable/" [WebSocket] for ::1 at 2017-08-02 12:03:37 +0200
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221437"} (via streamed from channel_1)
ChatChannel stopped streaming from channel_1
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221438"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221439"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221440"} (via streamed from channel_1)
ChatChannel is transmitting the unsubscribe confirmation
PHIL 1: ActionCable::Connection::ClientSocket receive_message
respond_to_successful_request: [-1, {}, []]
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221441"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221443"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221442"} (via streamed from channel_1)
Connection.disconnect

Q: Ok so this seems really weird. How is subscriptions the first thing being logged after disconnect?
Hmm seems like chatchannel transmit is "interferring" with it.

Q: Also: why is anything being transmitted when we've already disconnected?

subscriptions: []
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221444"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221445"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221446"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221447"} (via streamed from channel_1)
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221448"} (via streamed from channel_1)
ChatChannel transmitting {"type"=>"test", "content"=>"2969 221449"} (via streamed from channel_1)
Connection.connect
```

```log
Started GET "/cable" for ::1 at 2017-08-02 13:00:26 +0200
PHIL: ActionCable::Server::Base call
Started GET "/cable/" [WebSocket] for ::1 at 2017-08-02 13:00:26 +0200
PHIL 1: ActionCable::Connection::ClientSocket open
PHIL 2: ActionCable::Connection::ClientSocket open
PHIL: ApplicationCable::Connection on_open
respond_to_successful_request: [-1, {}, []]
subscriptions: []
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
Connection.connect
PHIL 1: ActionCable::Connection::ClientSocket receive_message
PHIL 2: ActionCable::Connection::ClientSocket receive_message
PHIL: ApplicationCable::Connection on_message
PHIL: ActionCable::Connection::MessageBuffer receive
connection#receive: {"command":"subscribe","identifier":"{\"channel\":\"ChatChannel\"}"}
dispatch_websocket_message: {"command":"subscribe","identifier":"{\"channel\":\"ChatChannel\"}"}
Subscribed
ChatChannel is transmitting the subscription confirmation
ChatChannel is streaming from channel_1
ChatChannel transmitting {"type"=>"test", "content"=>"5528 9568"} (via streamed from channel_1)
PHIL 1: ActionCable::Connection::ClientSocket finalize_close
PHIL 2: ActionCable::Connection::ClientSocket finalize_close
PHIL: ApplicationCable::Connection on_close
Finished "/cable/" [WebSocket] for ::1 at 2017-08-02 13:00:26 +0200
PHIL: unsubscribed
Unsubscribed
ChatChannel stopped streaming from channel_1
ChatChannel is transmitting the unsubscribe confirmation
Connection.disconnect

So I think the crux of the problem is here:
We receive the subscribe message "during" open, meaning the @ready_state
of the socket is not "OPEN" yet. Buffering would be an option.

Started GET "/cable" for ::1 at 2017-08-02 13:00:26 +0200
PHIL: ActionCable::Server::Base call
Started GET "/cable/" [WebSocket] for ::1 at 2017-08-02 13:00:26 +0200
PHIL 1: ActionCable::Connection::ClientSocket openPHIL 1: ActionCable::Connection::ClientSocket receive_message

PHIL 2: ActionCable::Connection::ClientSocket open
PHIL: ApplicationCable::Connection on_open
respond_to_successful_request: [-1, {}, []]
Connection.connect
subscriptions: []
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
```
