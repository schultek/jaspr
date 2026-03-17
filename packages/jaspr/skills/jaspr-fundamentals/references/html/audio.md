# audio

Signature of the audio component:

```dart
const audio(List<Component> children, {
  bool autoplay = false,
  bool controls = false,
  CrossOrigin? crossOrigin, // One of `.anonymous`, `.useCredentials`
  bool loop = false,
  bool muted = false,
  Preload? preload, // One of `.none`, `.metadata`, `.auto`
  String? src,
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
audio(autoplay: true, [
  // ...
])
```