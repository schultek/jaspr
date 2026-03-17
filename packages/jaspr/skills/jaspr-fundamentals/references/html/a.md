# a

Signature of the a component:

```dart
const a(List<Component> children, {
  /// The URL that the hyperlink points to. Links are not restricted to HTTP-based URLs — they can use any URL scheme supported by browsers:
  /// 
  /// Sections of a page with fragment URLs
  /// Pieces of media files with media fragments
  /// Telephone numbers with tel: URLs
  /// Email addresses with mailto: URLs
  /// While web browsers may not support other URL schemes, web sites can with registerProtocolHandler()
  required String href,
  /// Where to display the linked URL, as the name for a browsing context (a tab, window, or <iframe>).
  Target? target, // One of `.self`, `.blank`, `.parent`, `.top`
  /// Hints at the linked URL's format with a MIME type. No built-in functionality.
  String? type,
  /// Causes the browser to treat the linked URL as a download. Can be used with or without a value:
  /// 
  /// Without a value, the browser will suggest a filename/extension, generated from various sources:
  /// The Content-Disposition HTTP header
  /// The final segment in the URL path
  /// The media type (from the Content-Type header, the start of a data: URL, or Blob.type for a blob: URL)
  /// Defining a value suggests it as the filename. / and \ characters are converted to underscores (_). Filesystems may forbid other characters in filenames, so browsers will adjust the suggested name if necessary.
  String? download,
  /// How much of the referrer to send when following the link.
  ReferrerPolicy? referrerPolicy, // One of `.noReferrer`, `.noReferrerWhenDowngrade`, `.origin`, `.originWhenCrossOrigin`, `.sameOrigin`, `.strictOrigin`, `.strictOriginWhenCrossOrigin`, `.unsafeUrl`
  /// Callback for the 'click' event. This will override the default behavior of the link and not visit [href] when clicked.
  VoidCallback? onClick,
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
a(href: '...', [
  // ...
])
```