# StatelessComponent

Similar to Flutter, you can extract parts of your component tree into your own custom components.
A simple stateless component would extend the [StatelessComponent] class and must override the 
[build()] method.

A simple stateless component defining a custom [build()] method looks like this:

```dart
class MyComponent extends StatelessComponent {
  const MyComponent({Key? key}) : super(key: key);

  Component build(BuildContext context) {
    return div([...]);
  }
}
```

# Task

Refactor the Hello World app to use a custom [StatelessComponent] called [App] and provide this
component to the [runApp] method.
