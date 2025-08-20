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

  Component build(BuildContext context) {
    return div([...]);
  }
}
```

# Task

1. Create a new file called `counter.dart`
2. Add a new [StatefulComponent] called `Counter` inside the new file. 
   Let it render a single [Text] component for now.
3. Import the new file in your `main.dart` and use the [Counter] component beneath the `div` component.
   <details>
     <summary>Tip</summary>
     Use the `Fragment` component to return multiple children.
   </details>
