# Counter

Inside `counter.dart` we want to build a working counter component.

The UI for a simple counter consists of two parts:

1. A text displaying the current value and
2. A button that increments the value when clicked

---

## Events

A html component can have a set of events, each given a name and a callback. When the dom element triggers
a specified event, the callback is invoked.

Some html components, like `button()` have predefined typed event callbacks you can use, like `onClick`.

A button component listening to a *click* event looks like this:

```
button(
  onClick: () {
    // do something
  },
  [...],
);
```

# Task

1. Inside [Counter]s State add a new `int count` variable and initialize it to zero.
2. Display the count value using the [Text] component in the format `Count: <count>`.
   <details>
     <summary>Tip</summary>
     Use String interpolation with `'Count: $count'`.
   </details>
3. Add a new button element beneath the text element and give it a `onClick` event handler.
4. Increment the count inside the event handler and trigger a rebuild.
   <details>
     <summary>Tip</summary>
     Use `setState(() { ... });` to trigger a rebuild.
   </details>
