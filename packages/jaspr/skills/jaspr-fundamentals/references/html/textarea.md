# textarea

Signature of the textarea component:

```dart
const textarea(List<Component> children, {
  /// Indicates whether the value of the control can be automatically completed by the browser.
  AutoComplete? autoComplete, // One of `.off`, `.on`
  /// This attribute lets you specify that a form control should have input focus when the page loads. Only one form-associated element in a document can have this attribute specified.
  bool autofocus = false,
  /// The visible width of the text control, in average character widths. If it is specified, it must be a positive integer. If it is not specified, the default value is 20.
  int? cols,
  /// Indicates that the user cannot interact with the control. If this attribute is not specified, the control inherits its setting from the containing element, for example <fieldset>; if there is no containing element when the disabled attribute is set, the control is enabled.
  bool disabled = false,
  /// The minimum number of characters (UTF-16 code units) required that the user should enter.
  int? minLength,
  /// The name of the control
  String? name,
  /// A hint to the user of what can be entered in the control. Carriage returns or line-feeds within the placeholder text must be treated as line breaks when rendering the hint.
  String? placeholder,
  /// Indicates that the user cannot modify the value of the control. Unlike the disabled attribute, the readonly attribute does not prevent the user from clicking or selecting in the control. The value of a read-only control is still submitted with the form.
  bool readonly = false,
  /// This attribute specifies that the user must fill in a value before submitting a form.
  bool required = false,
  /// The number of visible text lines for the control. If it is specified, it must be a positive integer. If it is not specified, the default value is 2.
  int? rows,
  /// Specifies whether the <textarea> is subject to spell checking by the underlying browser/OS.
  SpellCheck? spellCheck, // One of `.isTrue`, `.isDefault`, `.isFalse`
  /// Indicates how the control wraps text. If this attribute is not specified, soft is its default value.
  TextWrap? wrap, // One of `.hard`, `.soft`
  /// Callback for the 'input' event.
  ValueChanged<String>? onInput,
  /// Callback for the 'change' event.
  ValueChanged<String>? onChange,
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
textarea(autoComplete: .off, [
  // ...
])
```