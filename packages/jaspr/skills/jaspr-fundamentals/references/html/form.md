# form

Signature of the form component:

```dart
const form(List<Component> children, {
  String? action,
  FormMethod? method, // One of `.post`, `.get`, `.dialog`
  FormEncType? encType, // One of `.formUrlEncoded`, `.multiPart`, `.text`
  AutoComplete? autoComplete, // One of `.off`, `.on`
  String? name,
  bool noValidate = false,
  Target? target, // One of `.self`, `.blank`, `.parent`, `.top`
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
form(action: '...', [
  // ...
])
```