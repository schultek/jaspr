# option

Signature of the option component:

```dart
const option(List<Component> children, {
  /// This attribute is text for the label indicating the meaning of the option. If the label attribute isn't defined, its value is that of the element text content.
  String? label,
  /// The content of this attribute represents the value to be submitted with the form, should this option be selected. If this attribute is omitted, the value is taken from the text content of the option element.
  String? value,
  /// Indicates that the option is initially selected. If the <option> element is the descendant of a <select> element whose multiple attribute is not set, only one single <option> of this <select> element may have the selected attribute.
  bool selected = false,
  /// If this attribute is set, this option is not checkable. Often browsers grey out such control and it won't receive any browsing event, like mouse clicks or focus-related ones. If this attribute is not set, the element can still be disabled if one of its ancestors is a disabled <optgroup> element.
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
option(label: '...', [
  // ...
])
```