
### Routing

1. Router Component over File-based routing

- More Darty
- Easier to understand, less to learn, more dynamic in project structure

2. Server: Handler over Server (like Remix)

- Just a handler, not a server

3. Responsibilities

- Render html on server
- Hydrate on client
- Preload new routes

- server
  - authenticate (may reject / redirect)
  - load data
  - render component
- client
  - receive data
  - render component
  - prefetch / navigate to route
