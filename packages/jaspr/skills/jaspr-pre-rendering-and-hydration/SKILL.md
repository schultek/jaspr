---
name: jaspr-pre-rendering-and-hydration
description: Use when working in a **static** or **server** mode Jaspr project. Covers SSR/SSG, async data fetching, the @client annotation, hydration, and handling dual entrypoints (.server.dart vs .client.dart).
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
- **Rule 1:** All parameters MUST be initializing fields (e.g., `const MyClientComponent({required this.title});`) or primary constructor parameters (e.g., `class MyClientComponent({this.title})`).
- **Rule 2:** Data parameters MUST be serializable:
  - Primitive types: `int`, `double`, `String`, `bool`, `List`, `Map`.
  - Enums or custom types: MUST define `@encoder` and `@decoder` methods.
- **Rule 3:** Components CAN be passed as parameters (`Component` or `List<Component>`). When a component is passed to a `@client` component, it becomes a **Server Component** (see below).
- **Rule 4:** Parameters MUST NOT be functions or other non-serializable, non-component types.

---

## Server Components (Surgical Hydration)

Server Components allow `@client` components to accept child components as constructor parameters, rendering them exclusively on the server and avoiding compiling or shipping their code to the browser.

### Benefits of Server Components
1. **Zero Client Footprint:** Static content inside interactive wrappers is not compiled to JS/Wasm. Only the wrapper shell is shipped to the client.
2. **Surgical Hydration:** The client app hydrates only the interactive boundary and mounts pre-rendered server DOM nodes into position (`<!--s@...-->` markers).
3. **Access to Server APIs:** The server component can use `dart:io`, query databases, or read the filesystem, even while visually hosted inside an interactive client component.
4. **Nested Islands:** Server components can in turn contain nested `@client` components, enabling clean alternating scopes (Server -> Client -> Server -> Client).

### Crucial Server Component Rules
- **Rule 1 (SSR Visibility):** Server components MUST be rendered during the initial server-side build. You MUST NOT conditionally exclude them using Dart `if` branches in the `@client` component's build method (e.g. `if (isOpen) component.child`), because the client does not possess the code to construct them later. Instead, always render the child and toggle visibility using CSS (e.g., `display: none` or `.hidden` class).
- **Rule 2 (Styling Server Content):** If a client component needs to style or augment server-rendered children, use `Component.apply(classes: '...', styles: ..., child: component.child)`.

### Example: Expandable Card with Server Component Content

```dart title="lib/components/expandable_card.dart"
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

// Interactive client-side wrapper
@client
class ExpandableCard extends StatefulComponent {
  const ExpandableCard({required this.title, required this.content, super.key});

  final String title;
  // Child component rendered entirely on the server
  final Component content;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isExpanded = false;

  @override
  Component build(BuildContext context) {
    return div(classes: 'card', [
      div(classes: 'card-header', [
        h3([.text(component.title)]),
        button(
          onClick: () => setState(() => isExpanded = !isExpanded),
          [.text(isExpanded ? 'Collapse' : 'Expand')],
        ),
      ]),
      // CRITICAL: Always include component.content in the tree so it is rendered during SSR!
      // Toggle visibility on the client via CSS classes rather than Dart if-checks.
      div(
        classes: 'card-content ${isExpanded ? 'expanded' : 'collapsed'}',
        [component.content],
      ),
    ]);
  }
}
```

Usage on the server:

```dart title="lib/main.server.dart"
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';
import 'components/expandable_card.dart';

void main() {
  runApp(Document(
    body: ExpandableCard(
      title: 'Server Details',
      // This div and its children are NEVER shipped to the client bundle!
      content: div([
        p([.text('Rendered statically on the server.')]),
      ]),
    ),
  ));
}
```

---

### Fetching Data on the Server (Async Components)

When pre-rendering in `server` or `static` mode, fetch data asynchronously (e.g., from a database or API) *before* rendering the HTML using Jaspr's server-only async components.

- **Rule 1:** You MUST use `AsyncStatelessComponent` or `AsyncBuilder` to perform async work during the build phase.
- **Rule 2:** These components MUST ONLY be used on the server (import `package:jaspr/server.dart`).
- **Rule 3:** Once data is fetched on the server, pass it to `@client` components as serialized parameters (primitives or `@encoder`/`@decoder` types), or wrap server-only content in a server component child.

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
      .text('This is static server content.'),
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

