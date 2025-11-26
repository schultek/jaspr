# Dart Frog Backend Example

An example application built with dart_frog & Jaspr.

## Running the App

1. Ensure you have activated both the `jaspr_cli` and `dart_frog_cli` packages:

   ```bash
   dart pub global activate jaspr_cli
   dart pub global activate dart_frog_cli
   ```

2. Run Jaspr using the `--skip-server` flag to prevent it from starting its own server, as dart_frog will handle that:

   ```bash
   jaspr serve --skip-server
   ```

3. In a separate terminal, start the dart_frog server. 
  Make sure to set the `JASPR_PROXY_PORT` environment variable to match the port Jaspr is using (default is 5567):

   ```bash  
   JASPR_PROXY_PORT=5567 dart_frog dev
   ```

## Routes

When served, the app has three routes configured:

- '/' (the index route)

  A standard dart_frog route that just responds with some text.

- '/counter'

  A route that renders the `Counter` component. This shows how jaspr can automatically 
  make a component interactive on the client.
  
- '/hello/[name]'

  A dynamic route that uses the 'name' parameter inside the rendered component.
