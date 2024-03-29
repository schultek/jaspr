# StatefulComponent

In addition to [StatelessComponent] there is also [StatefulComponent].

It again behaves the same as the [StatefulWidget] equivalent from Flutter. It defines a [State]
class that can hold mutable state and rebuilds when the state changes.

A simple stateful component looks like this:

```dart
class MyComponent extends StatefulComponent {
  const MyComponent({Key? key}): super(key: key);

  State createState() => MyComponentState();
}

class MyComponentState extends State<MyComponent> {

  Iterable<Component> build(BuildContext context) sync* {
    yield div([...]);
  }
}
```

It again defines the `build()` method using the [**Sync Generator**](https://dart.dev/guides/language/language-tour#generators) pattern.

# Task

1. Create a new file called `counter.dart`
2. Add a new [StatefulComponent] called `Counter` inside the new file. 
   Let it render a single [Text] component for now.
3. Import the new file in your `main.dart` and use the [Counter] component beneath the `div` component.
   <details>
     <summary>Tip</summary>
     Use `yield` a second time inside the `App`s build method.
   </details>
