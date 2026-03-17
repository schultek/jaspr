# link

Signature of the link component:

```dart
const link({
  /// This attribute specifies the URL of the linked resource. A URL can be absolute or relative.
  required String href,
  /// This attribute names a relationship of the linked document to the current document. The attribute must be a space-separated list of link type values.
  String? rel,
  /// This attribute is used to define the type of the content linked to. The value of the attribute should be a MIME type such as text/html, text/css, and so on. The common use of this attribute is to define the type of stylesheet being referenced (such as text/css), but given that CSS is the only stylesheet language used on the web, not only is it possible to omit the type attribute, but is actually now recommended practice. It is also used on rel="preload" link types, to make sure the browser only downloads file types that it supports.
  String? type,
  /// This attribute is only used when rel="preload" or rel="prefetch" has been set on the <link> element. It specifies the type of content being loaded by the <link>, which is necessary for request matching, application of correct content security policy, and setting of correct Accept request header. Furthermore, rel="preload" uses this as a signal for request prioritization.
  String? as,
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
link(href: '...')
```