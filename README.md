# README

## Setup:

### Action Cable Client

Have one action cable client (`client.rb`) running.

1. This client connects to the action cable server and
2. subscribes to the `ChatChannel`.
3. When the client receives a message from that channel it will disconnect and
   start the process from 1.

### Broadcast source

Have several (3) broadcast sources running.

In `broadcast.rb` we broadcast 100 000 messages to the cable client. After
sending a message we sleep for 0.1 seconds.

## Observeration:

At a certain point the client connects, but doesn't receive the subcription
confirmation and therefore misses broadcast messages.

`client.rb`:

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

rails server:

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

Previous runs:

1. failure occurred at message 2000
2. failure didn't occurr (10000 msgs)
3. failure occurred at message 3595
4.
