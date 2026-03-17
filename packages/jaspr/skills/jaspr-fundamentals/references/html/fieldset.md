# fieldset

Signature of the fieldset component:

```dart
const fieldset(List<Component> children, {
  /// The name associated with the group.
  String? name,
  /// If this Boolean attribute is set, all form controls that are descendants of the <fieldset>, are disabled, meaning they are not editable and won't be submitted along with the <form>. They won't receive any browsing events, like mouse clicks or focus-related events. By default browsers display such controls grayed out. Note that form elements inside the <legend> element won't be disabled.
  bool disabled = false,
  String? id,
  String? classes,
  Styles? styles,
  Map<String, String>? attributes,
  Map<String, EventCallback>? events,
  Key? key,
})
```

Example usage:

```dart
fieldset(name: '...', [
  // ...
])
```