# meta

Signature of the meta component:

```dart
const meta({
  /// The name and content attributes can be used together to provide document metadata in terms of name-value pairs, with the name attribute giving the metadata name, and the content attribute giving the value.
  /// See standard metadata names for details about the set of standard metadata names defined in the HTML specification.
  String? name,
  /// This attribute contains the value for the 'http-equiv' or 'name' attribute, depending on which is used.
  String? content,
  /// This attribute declares the document's character encoding. If the attribute is present, its value must be an ASCII case-insensitive match for the string "utf-8", because UTF-8 is the only valid encoding for HTML5 documents. <meta> elements which declare a character encoding must be located entirely within the first 1024 bytes of the document.
  String? charset,
  /// Defines a pragma directive. The attribute's name, short for http-equivalent, is because all the allowed values are names of particular HTTP headers.
  String? httpEquiv,
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
meta(name: '...')
```