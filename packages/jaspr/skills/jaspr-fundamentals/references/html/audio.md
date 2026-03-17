# audio

Signature of the audio component:

```dart
const audio(List<Component> children, {
  /// A Boolean attribute: if specified, the audio will automatically begin playback as soon as it can do so, without waiting for the entire audio file to finish downloading.
  bool autoplay = false,
  /// If this attribute is present, the browser will offer controls to allow the user to control audio playback, including volume, seeking, and pause/resume playback.
  bool controls = false,
  /// Indicates whether to use CORS to fetch the related audio file.
  CrossOrigin? crossOrigin, // One of `.anonymous`, `.useCredentials`
  /// If specified, the audio player will automatically seek back to the start upon reaching the end of the audio.
  bool loop = false,
  /// Indicates whether the audio will be initially silenced. Its default value is false.
  bool muted = false,
  /// Provides a hint to the browser about what the author thinks will lead to the best user experience.
  Preload? preload, // One of `.none`, `.metadata`, `.auto`
  /// The URL of the audio to embed. This is subject to HTTP access controls. This is optional; you may instead use the <source> element within the audio block to specify the audio to embed.
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