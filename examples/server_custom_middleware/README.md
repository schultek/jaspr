# Custom Server Middleware Example

This example demonstrates the use of custom server middleware in a jaspr app.

Middleware sits in between the http server and jasprs rendering handler and can control or monitor
how requests are served by the server.

## Setup

Given you have a standard server entrypoint calling `runApp`, replace this function with `runServer` 
which is exposed through the `package:jaspr/server.dart` library:

```dart
// server specific import
import 'package:jaspr/server.dart';

import 'app.dart';

void main() async {
  // Uses [runServer] in place of [runApp] to retrieve the [ServerApp] instance.
  ServerApp app = runServer(Document(body: App()));
}
```

The `ServerApp` class has different methods to hook into the http server that is created by jaspr.

For this example, we are interested in the `.addMiddleware(Middleware middleware)` method.

The `Middleware` type comes from `package:shelf` as jaspr uses shelf internally. So you can put in any 
shelf middleware or write your own.

---

The following line adds the `logRequests` middleware from the shelf package:

```dart

// Adds the standard shelf logging middleware to print out any incoming request.
app.addMiddleware(logRequests());
```

The example also adds additional middleware to show the integration of an api endpoint.
