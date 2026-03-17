# source

Signature of the source component:

```dart
const source({
  /// Address of the media resource.
  /// 
  /// Required if the source element's parent is an <audio> and <video> element, but not allowed if the source element's parent is a <picture> element.
  String? src,
  /// The MIME media type of the resource, optionally with a codecs parameter.
  String? type,
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
source(src: '...')
```