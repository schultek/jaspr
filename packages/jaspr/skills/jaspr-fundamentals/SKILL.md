---
name: jaspr-fundamentals
description: Use when working in a Jaspr project, on Jaspr components, or other Jaspr-related tasks. Contains fundamentals of writing Jaspr components and using HTML components.
metadata:
  jaspr_version: 0.23.3
---

## Components

Jaspr uses a component-based architecture very similar to Flutter's widgets. Concepts like ui composition, architecture and state management are transferable.

- **StatelessComponent**: For components that don't need mutable state. You must override `Component build(BuildContext context)`.
- **StatefulComponent**: For components with mutable state. Requires an associated `State` class. The state has lifecycle methods like `initState()` and `dispose()`. You must override `Component build(BuildContext context)` in the state class.
- **InheritedComponent**: For propagating context or state efficiently down the component tree.

### Returning Components from `build`

Building UIs in Jaspr requires you to return a single `Component` from `build()`.

- **Rule 1:** You MUST NOT use `Iterable<Component> build(BuildContext context) sync*`. This is legacy code.
- **Rule 2:** You MUST use dot-shorthands instead of capitalized component names for fragments, text, and empty nodes.
  - Use `.fragment([...])` (Do NOT use `Fragment([...])` or `fragment([...])`).
  - Use `.text('...')` (Do NOT use `Text('...')` or `text('...')`).
  - Use `.empty()` to return an empty space safely.

**Example Usage:**
```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class MyComponent extends StatelessComponent {
  const MyComponent({super.key});

  @override
  Component build(BuildContext context) {
    // 1. Return a single component (e.g. div)
    // 2. Use dot-shorthand (.text) instead of Text()
    return div(classes: 'my-class', [
      .text('Hello World'),
    ]);
  }
}
```

### Creating a Component

The `jaspr new` CLI command can be used to create new components.

- **Rule 1:** You SHOULD use the `jaspr new component` command to create a new component file, then edit the generated `build` method.
- **Rule 2:** You MAY also hand-write a new component file from scratch, depending on situations.

```bash
jaspr new component ContactInfo            # StatelessComponent, creates lib/components/contact_info.dart
jaspr new component TodoList --stateful    # StatefulComponent, with its State class
jaspr new component AppTheme --inherited   # InheritedComponent, creates lib/app_theme.dart

# Creates a FlutterEmbedView, and sets the project up for flutter embedding
jaspr new component CounterView --flutter --flutter-app-name CounterWidget --with-flutter-widget
```

Useful options:

- `--path <dir>`: where the file is created (defaults to `lib/components`)
- `--with-styles`: adds the `@css` styles getter, see [jaspr-styling](../jaspr-styling/SKILL.md)
- `--client`: adds the `@client` annotation, see [jaspr-pre-rendering-and-hydration](../jaspr-pre-rendering-and-hydration/SKILL.md)
- `--async`: creates an `AsyncStatelessComponent` for server-side data fetching
- `--with-test`: also generates a matching test under `test/`
- `--dry-run`: prints what would be created without writing anything
- `--flutter-app-name` (or `--app-name`): name of the Flutter widget to embed, only used with `--flutter`. 
- `--with-sample-flutter-widget` (or `--with-flutter-widget`): generates a sample Flutter widget with the name of the flutter app, only used with `--flutter`. The flag is negatable, and if it is not passed at all then the command prompts for it.


The name can be PascalCase, camelCase or snake_case. Run the command once per component instead of creating several files in one edit.

## HTML Components

Jaspr provides typed components for standard HTML elements (e.g., `div()`, `p()`, `a()`, `button()`). To use these add the `package:jaspr/dom.dart` import. 

All HTML components take standard named `Key? key`, `String? id`, `String? classes`, `Styles? style`, `Map<String, String>? attributes` and `Map<String, void Function(Event)>? events` parameters.
Most HTML components take a positional `List<Component> children` parameter (except for self-closing tags like `img`, `input`, `br`, etc.).

- **Rule 1:** ALWAYS put the `children` list LAST, after all named parameters.
- **Rule 2:** You MUST prefer available typed parameters (e.g., `href`, `src`, `onClick`) over using the raw `attributes:` or `events:` maps.
- **Rule 3:** When you are unsure about which typed parameters exist for an HTML component, you **MUST** read the respective reference file provided alongside this skill:
  - `references/html/<tag>.md` contains the full signature and example usage of the component for the given tag. (e.g. `references/html/div.md` for `div()`, `references/html/button.md` for `button()`, etc.)
- **Rule 4:** When a respective reference file does not exist for a tag (and therefore the component itself doesn't exist), you **MUST** use the generic `.element(tag: '...', /* other standard params, */ children: [ /* ... */ ])` constructor instead.

**Example Usage:**
```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class MyHtmlComponent extends StatelessComponent {
  const MyHtmlComponent({super.key});

  @override
  Component build(BuildContext context) {
    return div(id: 'my-container', classes: 'my-class', [ 
      p(attributes: {'aria-label': 'Example Paragraph'}, [
        .text('Hello World'),
      ]),
      // E.g. signature as found at 'references/html/a.md'
      a(href: 'https://example.com', [
        .text('Click me'),
      ]),
    ]);
  }
}
```

## Styling Components

Jaspr has built-in support for styling components using CSS-in-Dart. 
See the [jaspr-styling](../jaspr-styling/SKILL.md) skill for more information.

## Interactivity and Events

### 1. Accessing Browser APIs

- **Rule 1:** In **server** or **static** mode, you MUST use `package:universal_web/web.dart` to access browser APIs and `package:universal_web/js_interop.dart` to access js interop APIs.
- **Rule 2:** When using `package:universal_web` in **server** or **static** mode, you MUST wrap all API calls in an `if (kIsWeb)` check to prevent crashing the server render.
- **Rule 3:** In **client** mode, you can use `dart:js_interop` and `package:web` directly.
- **Rule 4:** For global events, you MUST use `web.EventStreamProviders` to listen to events on the `window` or `document` as they provide a typed Dart `Stream` of events.

```dart
// Example of safe usage in server/static mode:
import 'package:universal_web/web.dart' as web;

void logSize() {
  if (kIsWeb) {
    print('Window size: ${web.window.innerWidth}x${web.window.innerHeight}');

    // Example of global event listener
    final sub = web.EventStreamProviders.resizeEvent.forTarget(web.window).listen((event) {
      print('Window resized');
    });
  }
}
```

### 2. Handling Events

All DOM components support an `events:` parameter, and interactive components feature typed event callbacks (like `onClick`, `onChange`).
- **Rule 1:** You MUST use `web.Event` when typing raw events.
- **Rule 2:** Use the `events()` helper function for type-safe callback creation when needed.

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:universal_web/web.dart' as web;

class MyButton extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return div(
      // Using raw events
      events: {'click': (web.Event event) {
        print('Div clicked');
      }},
      [
        // Using typed parameters
        button(
          onClick: () => print('Button clicked'),
          [.text('Click me')]
        )
      ]
    );
  }
}
```


### 3. Accessing Elements (GlobalNodeKey)

If you need direct reference to an underlying DOM element rendered by Jaspr, you can assign it a `GlobalNodeKey`.

```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';
import 'package:universal_web/web.dart' as web;

class MyInput extends StatefulComponent {
  @override
  State<MyInput> createState() => _MyInputState();
}

class _MyInputState extends State<MyInput> {
  final GlobalNodeKey<web.HTMLInputElement> inputKey = GlobalNodeKey();

  void focusInput() {
    inputKey.currentNode?.focus();
  }

  @override
  Component build(BuildContext context) {
    return input(key: inputKey, type: .text);
  }
}
```

---

## Further Resources

- For information on pre-rendering, async data fetching, hydration, and the `@client` annotation see the related skill: [jaspr-pre-rendering-and-hydration](../jaspr-pre-rendering-and-hydration/SKILL.md).
- For information on styling components see the related skill: [jaspr-styling](../jaspr-styling/SKILL.md).
- For information on how to convert HTML to Jaspr code, see the related skill: [jaspr-convert-html](../jaspr-convert-html/SKILL.md).
- An index of all available documentation can be found at [https://jaspr.site/llms.txt](https://jaspr.site/llms.txt).