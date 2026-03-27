---
name: jaspr-pre-rendering-and-hydration
description: Use when working in a **static** or **server** mode Jaspr project. Covers SSR/SSG, async data fetching, the @client annotation, hydration, and handling dual entrypoints (.server.dart vs .client.dart).
metadata:
  jaspr_version: 0.22.4
---

This skill is relevant for **static** and **server** mode Jaspr projects. You can check the mode of a Jaspr project in `pubspec.yaml` under `jaspr: mode: <mode>`.

## Core Rules for Pre-rendering (SSR/SSG)

Jaspr pre-renders components at request/build-time on the server. Interactive browser features require hydration.

1. **Dual Entrypoints:** 
   - **Server:** `lib/main.server.dart` -> Calls `runApp(Document(body: MyApp()))`
   - **Client:** `lib/main.client.dart` -> Calls `runApp(ClientApp())`
2. **Library Constraints:** 
   - **Importing:** You MUST NOT import `dart:js_interop` or `package:web` in any code imported by the server entrypoint.
   - **Importing:** You MUST NOT import `dart:io` or `dart:ffi` in any code imported by the client entrypoint.
   - **Using:** You can import `package:universal_web` in shared code, but you MUST wrap any access to its browser APIs inside an `if (kIsWeb)` check to prevent crashing during server-side rendering.
3. **Interactivity / Hydration:** Components are server-rendered by default. To add client interactivity (e.g., event listeners, state, using browser APIs), you **MUST** annotate a component with `@client`. 

### The `@client` Annotation and `ClientApp`

When you annotate a component with `@client`, Jaspr renders its initial HTML on the server and "hydrates" it in the browser.

- `ClientApp()` (called in the client entrypoint) automatically looks for and hydrates all `@client` components that were pre-rendered on the server.
- **Rule:** Only the **uppermost** component of a subtree that needs client interactivity needs to be annotated with `@client`. Do not annotate child components in that subtree, they will automatically be hydrated as part of the parent.

### Passing Data to `@client` Components

Use parameters of `@client` components to pass data from the server to the client. These are automatically serialized on the server and deserialized in the browser.
- **Rule 1:** All parameters MUST be initializing fields (e.g., `const MyClientComponent({required this.title});`).
- **Rule 2:** All parameters MUST be serializable. They must be primitive types (`int`, `String`, `double`, `bool`, `List`, `Map`) OR custom types that define `@encoder` and `@decoder` methods.
  - Parameters MUST NOT be functions, components, or any other non-serializable types.

### Fetching Data on the Server (Async Components)

When pre-rendering in `server` or `static` mode, you often need to fetch data asynchronously (e.g., from a database or API) *before* rendering the HTML. Jaspr provides special server-only components to delay the build phase until the data is ready.

- **Rule 1:** You MUST use `AsyncStatelessComponent` or `AsyncBuilder` to perform async work during the build phase.
- **Rule 2:** These components MUST ONLY be used on the server (import `package:jaspr/server.dart`).
- **Rule 3:** Once the data is fetched on the server, you should pass it to a `@client` component as a parameter if you need that data to be available for client-side interactivity.

**Example Usage:**

```dart title="lib/my_server_component.dart"
import 'package:jaspr/server.dart'; // Note the server-only import!
import 'package:jaspr/dom.dart';

import 'my_interactive_button.dart';

// This component fetches data before server-rendering the HTML.
class MyServerComponent extends AsyncStatelessComponent {
  const MyServerComponent();

  @override
  Future<Component> build(BuildContext context) async {
    // 1. Fetch data asynchronously on the server
    final databaseCount = await loadCountFromDatabase();

    return div([
      .text('This is static.'),
      // 2. Pass the fetched data to the client component
      MyInteractiveButton(initialCount: databaseCount), 
    ]);
  }
}
```

```dart title="lib/my_interactive_button.dart"
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

// This component runs in the browser (interactive).
@client
class MyInteractiveButton extends StatefulComponent {
  const MyInteractiveButton({this.initialCount = 0});

  final int initialCount;

  @override
  State<MyInteractiveButton> createState() => _MyInteractiveButtonState();
}

class _MyInteractiveButtonState extends State<MyInteractiveButton> {
  late int count = component.initialCount;

  @override
  Component build(BuildContext context) {
    return button(
      onClick: () => setState(() => count++),
      [.text('Clicked $count times')],
    );
  }
}
```
