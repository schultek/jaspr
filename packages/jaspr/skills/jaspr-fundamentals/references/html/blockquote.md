# blockquote

Signature of the blockquote component:

```dart
const blockquote(List<Component> children, {
  /// A URL that designates a source document or message for the information quoted. This attribute is intended to point to information explaining the context or the reference for the quote.
  String? cite,
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
blockquote(cite: '...', [
  // ...
])
```