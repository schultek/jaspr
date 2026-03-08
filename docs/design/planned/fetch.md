

## Concept: Universal fetch

- Idea: The public api is always about fetching data from a route, but
  - on the server, the request is routed directly internally to the right handler without going over http
  - on the client, either
    - the data already exists because of ssr and is returned immediately
    - the data needs to be (re)-fetched and the server route is called

- Pros: Single logic block for client & server
- Cons: Not compile safe (when using plain strings,
  but routes could be made constants (like riverpod providers) and be compiled safe)

```dart

// server

void main() {
  runApp(Handler(
    handlers: {
      '/users': Handle.data(loadUsers),
      '/users/new': Handle.action(addNewUser),
    },
    home: App(),
  ));
}

Future<List<User>> loadUsers() {
  return db.users.findAll();
}

Future<void> addNewUser(UserRequest request) async {
  await db.users.add(request.user);
}

// component

class App extends StatelessComponent {

  Component build(BuildContext context) {
    return Loader<List<User>>(
      route: '/users',
      builder: (BuildContext context, AsyncValue<List<User>> userState) {
        // ...
        // Handler.trigger('/users/new', UserRequest.new(...))
      },
    );
  }
}

```
