# dart_quotes_server

A demo app built with Jaspr and Serverpod.

## Running the project

Run your project using `jaspr serve`.

To run your server, you first need to start Postgres and Redis. It's easiest to do with Docker.

    docker compose up --build --detach

Then you can start the server.

    jaspr serve

When you are finished, you can shut down the server with `Ctrl-C`, then stop Postgres and Redis.

    docker compose stop
