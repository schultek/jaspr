# video

Signature of the video component:

```dart
const video(List<Component> children, {
  /// Indicates if the video automatically begins to play back as soon as it can do so without stopping to finish loading the data.
  bool autoplay = false,
  /// If this attribute is present, the browser will offer controls to allow the user to control video playback, including volume, seeking, and pause/resume playback.
  bool controls = false,
  /// Indicates whether to use CORS to fetch the related video.
  CrossOrigin? crossOrigin, // One of `.anonymous`, `.useCredentials`
  /// If specified, the browser will automatically seek back to the start upon reaching the end of the video.
  bool loop = false,
  /// Indicates the default setting of the audio contained in the video. If set, the audio will be initially silenced. Its default value is false, meaning that the audio will be played when the video is played.
  bool muted = false,
  /// A URL for an image to be shown while the video is downloading. If this attribute isn't specified, nothing is displayed until the first frame is available, then the first frame is shown as the poster frame.
  String? poster,
  /// Provides a hint to the browser about what the author thinks will lead to the best user experience with regards to what content is loaded before the video is played.
  Preload? preload, // One of `.none`, `.metadata`, `.auto`
  /// The URL of the video to embed. This is optional; you may instead use the <source> element within the video block to specify the video to embed.
  String? src,
  /// The width of the video's display area, in CSS pixels.
  int? width,
  /// The height of the video's display area, in CSS pixels.
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