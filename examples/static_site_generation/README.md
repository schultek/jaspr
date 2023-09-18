# static_site_generation minimalistic example

A basic pure-dart web app with ssr & automatic client hydration.

Created using `jaspr create`with the default template and no flutter embedding.

Added router and simple about page to app.dart

Running `jaspr serve` will start a server on port 8080.

Running `jaspr generate` will generate a static site in the `build/jaspr` directory. This was intentionally checked in to give a quick example of what the output looks like.

To serve the static site I used https://github.com/http-party/http-server but any static file server should do, though I had trouble getting the python3 one to work with the about page, so if you cant navigate there, try a different http server.
