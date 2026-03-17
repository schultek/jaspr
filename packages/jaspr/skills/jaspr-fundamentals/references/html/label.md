# label

Signature of the label component:

```dart
const label(List<Component> children, {
  /// The value of the for attribute must be a single id for a labelable form-related element in the same document as the <label> element. So, any given label element can be associated with only one form control.
  String? htmlFor,
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
label(htmlFor: '...', [
  // ...
])
```