
## Concept: Controllers

- handle data loading / fetching / updating between server and client
- written for server, auto generated for client (-> TODO find out what to generate)
  - server: load data, handle actions
  - client: receive data, send actions

```dart
// server

final controller = ServerController<List<User>, UserRequest>(
    '/users',
    loader: () {
      return db.users.findAll();
    },
    action: (UserRequest request) async {
      await db.users.add(request.user);
    }
);

// client (generated)

final controller = ClientController('/users');

// shared / component

import 'controllers/user_controller.dart'
if (dart.library.html) 'controllers/user_controller.g.dart'
as users;

class UsersPage extends StatelessComponent {

  Iterable<Component> build(BuildContext context) sync* {
    yield Controlled(
      controller: users.controller,
      build: (BuildContext context, AsyncValue<List<User>> userState) sync* {
        yield userState.when(
          data: (List<User> users) sync* {
            yield Text('Users: ${users.length}');
            yield Button(
              child: Text('Add new'),
              onPressed: () {
                controller.dispatch(UserRequest.newUser('Tom'));
              },
            );
          },
          loading: () sync* {
            yield Text('Loading...');
          },
          error: (e) sync* {
            yield Text('Error: $e');
          },
        );
      },
    );
  }
}

```
