# form

Signature of the form component:

```dart
const form(List<Component> children, {
  /// The URL that processes the form submission. This value can be overridden by a formaction attribute on a <button>, <input type="submit">, or <input type="image"> element. This attribute is ignored when method="dialog" is set.
  String? action,
  /// The HTTP method to submit the form with.
  /// 
  /// This value is overridden by formmethod attributes on <button>, <input type="submit">, or <input type="image"> elements.
  FormMethod? method, // One of `.post`, `.get`, `.dialog`
  /// If the value of the method attribute is post, enctype is the MIME type of the form submission.
  FormEncType? encType, // One of `.formUrlEncoded`, `.multiPart`, `.text`
  /// Indicates whether input elements can by default have their values automatically completed by the browser. autocomplete attributes on form elements override it on <form>.
  AutoComplete? autoComplete, // One of `.off`, `.on`
  /// The name of the form. The value must not be the empty string, and must be unique among the form elements in the forms collection that it is in, if any.
  String? name,
  /// Indicates that the form shouldn't be validated when submitted. If this attribute is not set (and therefore the form is validated), it can be overridden by a formnovalidate attribute on a <button>, <input type="submit">, or <input type="image"> element belonging to the form.
  bool noValidate = false,
  /// Indicates where to display the response after submitting the form. In HTML 4, this is the name/keyword for a frame. In HTML5, it is a name/keyword for a browsing context (for example, tab, window, or iframe).
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