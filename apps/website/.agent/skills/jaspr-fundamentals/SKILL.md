---
name: jaspr-fundamentals
description: Use when working in a Jaspr project, on Jaspr components, or other Jaspr-related tasks. Contains basics of writing Jaspr components and using HTML components.
---

## Components

Jaspr uses a component-based architecture very similar to Flutter's widgets. Concepts like ui composition, architecture and state management are transferable.

- **StatelessComponent**: For components that don't need mutable state. You must override `Component build(BuildContext context)`.
- **StatefulComponent**: For components with mutable state. Requires an associated `State` class. The state has lifecycle methods like `initState()` and `dispose()`. You must override `Component build(BuildContext context)` in the state class.
- **InheritedComponent**: For propagating context or state efficiently down the component tree.

Example:
```dart
import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class MyComponent extends StatelessComponent {
  const MyComponent({super.key});

  @override
  Component build(BuildContext context) {
    return div(classes: 'my-class', [
      .text('Hello World'),
    ]);
  }
}
```

*Note: Using `Iterable<Component> build(BuildContext context) sync*` is legacy code and MUST NOT be used.

Building UIs in Jaspr requires you to return a single Component from `build()`. Sometimes you need to return multiple siblings or simple text:

- **`.fragment([...])`** or `Component.fragment([...])`: Groups multiple components together without rendering a wrapper DOM element. Commonly used when you want to return multiple siblings.
- **`.text('...')`** or `Component.text('...')`: Renders a simple standalone HTML text node.
- **`.empty()`** or `Component.empty()`: Helper to return an empty fragment. Useful for empty branches in logic safely returning nothing.

**Always prefer** the dot-shorthands syntax `.text(data)`, `.fragment(children)` and `.empty()`. 
*Note: Using `Text()`, `Fragment()` or `text()`, `fragment()` is legacy code and MUST NOT be used.*

## HTML Components

Jaspr provides typed components for standard HTML elements (e.g., `div()`, `p()`, `a()`, `button()`). To use these add the `package:jaspr/dom.dart` import.

Most HTML components take a positional list of `Component`s as their children, and named parameters `Key? key`, `String? id`, `String? classes`, `Styles? style`, `Map<String, String>? attributes` and `Map<String, void Function(Event)>? events`. ALWAYS put the children LAST, after all named parameters.

```dart
div(id: 'my-container', classes: 'my-class', [ 
  p(attributes: {'aria-label': 'Example Paragraph'}, [
    .text('Hello World'),
  ]),
  a(href: 'https://example.com', [
    .text('Click me'),
  ]),
])
```

### Typed Parameters

Some HTML components have additional typed parameters, such as `href` for `a` tags, `src` for `img` tags, `onClick` for `button` tags, etc. **Always prefer** the available typed parameters over using the raw attributes or events map.

To find out which parameters are available, run `jaspr tooling-daemon lookup-tag <tag>` in the terminal, which outputs the full signature of the component for the given tag. 

For example, to find out which parameters are available for the `button` component, run `jaspr tooling-daemon lookup-tag button`, which outputs:

```dart
/// The &lt;button&gt; HTML element is an interactive element activated by a user with a mouse, keyboard, finger, voice command, or other assistive technology. Once activated, it then performs a programmable action, such as submitting a form or opening a dialog.
const button(
  List<Component> children, {
  /// Specifies that the button should have input focus when the page loads. Only one element in a document can have this attribute.
  bool autofocus = false,
  /// Prevents the user from interacting with the button: it cannot be pressed or focused.
  bool disabled = false,
  /// The default behavior of the button.
  ButtonType? type, // One of `.submit`, `.reset`, `.button`
  /// Callback for the 'click' event.
  VoidCallback? onClick,
  String? id,
  String? classes,
  Styles? styles,
  Map<String, String>? attributes,
  Map<String, void Function(Event)>? events,
  Key? key,
});
```

Then you can use it like this:

```dart
button(
  id: 'my-button',
  autofocus: true,
  type: ButtonType.submit,
  onClick: () {
    print('Button clicked!');
  },
  [
    .text('Click me'),
  ],
);
```

## Interactivity and Events