# Conops Console

SwiftUI client for the Conops API.

## SSE Events

The app listens to server-sent events on `/api/v1/events` using `ConopsEventStream`.

Heartbeat/ping handling:

- The server sends `event: ping` with `data: ping` every 15 seconds.
- The client treats those as keepalive messages and ignores them for sync.
- See `conops-console/Controller/Server/ConopsEventStream.swift` for the parser.
