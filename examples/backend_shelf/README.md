# Shelf Backend Example

This example shows how to use a custom shelf server with Jaspr. 

## Overview

Usually when running `runApp` on the server, jaspr spins up its own http server. However if you
write your backend with dart, you might want to use your own server setup and just integrate jaspr
on some routes.

Jaspr supports being used with a custom server setup through the `serveApp` and `renderComponent` function.

`serveApp` is a shelf handler that serves your app with all required resources. Since it is a normal shelf handler,
it can be used anywhere a shelf handler is accepted.
In this example, it is mounted under the '/app' prefix to show how you can serve a jaspr app only under a subpath
of your domain.

`renderComponent` renders a single component and outputs the resulting html as a `String`. It can be directly returned
as a response or further used in your server.
