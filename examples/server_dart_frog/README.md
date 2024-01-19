# Dart Frog Backend Example

An example application built with dart_frog & jaspr.

## Routes

When served, the app has three routes configured:

- '/' (the index route)

  A standard dart_frog route that just responds with some text.

- '/counter'

  A route that renders the `Counter` component. This shows how jaspr can automatically 
  make a component interactive on the client.
  
- '/hello/[name]'

  A dynamic route that uses the 'name' parameter inside the rendered component.
