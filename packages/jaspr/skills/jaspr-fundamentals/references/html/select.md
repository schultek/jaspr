# select

Signature of the select component:

```dart
const select(List<Component> children, {
  /// This attribute is used to specify the name of the control.
  String? name,
  /// The value of the control.
  String? value,
  /// Indicates that multiple options can be selected in the list. If it is not specified, then only one option can be selected at a time. When multiple is specified, most browsers will show a scrolling list box instead of a single line dropdown.
  bool multiple = false,
  /// Indicating that an option with a non-empty string value must be selected.
  bool required = false,
  /// Indicates that the user cannot interact with the control. If this attribute is not specified, the control inherits its setting from the containing element, for example <fieldset>; if there is no containing element with the disabled attribute set, then the control is enabled.
  bool disabled = false,
  /// This attribute lets you specify that a form control should have input focus when the page loads. Only one form element in a document can have the autofocus attribute.
  bool autofocus = false,
  /// A string providing a hint for a user agent's autocomplete feature.
  String? autocomplete,
  /// If the control is presented as a scrolling list box (e.g. when multiple is specified), this attribute represents the number of rows in the list that should be visible at one time. Browsers are not required to present a select element as a scrolled list box. The default value is 0.
  int? size,
  /// Callback for the 'input' event.
  ValueChanged<List<String>>? onInput,
  /// Callback for the 'change' event.
  ValueChanged<List<String>>? onChange,
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
select(name: '...', [
  // ...
])
```