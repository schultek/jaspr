# StatelessComponent

Similar to Flutter, you can extract parts of your component tree into your own custom components.
A simple stateless component would extend the [StatelessComponent] class and must override the 
[build()] method.

A simple stateless component defining a custom [build()] method can look like this:

```dart
class MyComponent extends StatelessComponent {

  const MyComponent({Key? key}) : super(key: key);

  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(...);
  }
}
```

Notice that different to Flutter the `build()` method returns an [Iterable<Component>] instead of a single component.
This is a [**Design Principle**](https://github.com/schultek/jaspr/tree/main/packages/jaspr#differences-to-flutter) 
of Jaspr to better match the unique properties of the web platform compared to Flutter.

> The recommended way to write build methods with Jaspr is using the [**Sync Generator**](https://dart.dev/guides/language/language-tour#generators) pattern.
> Simply use the `sync*` keyword in the method definition and `yield` one or multiple components (instead of returning).

# Task

Refactor the Hello World app to use a custom [StatelessComponent] called [App] and provide this
component to the [runApp] method.