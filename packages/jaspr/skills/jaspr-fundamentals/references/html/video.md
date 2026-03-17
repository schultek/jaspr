# video

Signature of the video component:

```dart
const video(List<Component> children, {
  bool autoplay = false,
  bool controls = false,
  CrossOrigin? crossOrigin, // One of `.anonymous`, `.useCredentials`
  bool loop = false,
  bool muted = false,
  String? poster,
  Preload? preload, // One of `.none`, `.metadata`, `.auto`
  String? src,
  int? width,
  int? height,
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
video(autoplay: true, [
  // ...
])
```