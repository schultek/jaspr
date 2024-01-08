# Dart Frog Backend Example

An example application built with dart_frog & jaspr.

Run with the following commands (in parallel / separate terminals):

```
dart run webdev serve web:5467
jaspr_dev_proxy=5467 dart_frog dev
```

The first command runs the `webdev` tool and serves the content of the `web/` folder under port `5467`.
The second command runs the dev server of `dart_frog`. The `jaspr_dev_proxy` environment variable is
use by the jaspr middleware to proxy the compiles js files for the returned components.

## Routes

When served, the app has three routes configured:

- '/' (the index route)

  A standard dart_frog route that just responds with some text.

- '/counter'

  A route that renders the `Counter` component. This shows how jaspr can automatically 
  make a component interactive on the client.
  
- '/hello/[name]'

  A dynamic route that uses the 'name' parameter inside the rendered component.
