import '../../jaspr.dart';

/// The &lt;audio&gt; HTML element is used to embed sound content in documents. It may contain one or more audio sources, represented using the src attribute or the &lt;source&gt; element: the browser will choose the most suitable one. It can also be the destination for streamed media, using a MediaStream.
///
/// - [autoplay]: A Boolean attribute: if specified, the audio will automatically begin playback as soon as it can do so, without waiting for the entire audio file to finish downloading.
/// - [controls]: If this attribute is present, the browser will offer controls to allow the user to control audio playback, including volume, seeking, and pause/resume playback.
/// - [crossOrigin]: Indicates whether to use CORS to fetch the related audio file.
/// - [loop]: If specified, the audio player will automatically seek back to the start upon reaching the end of the audio.
/// - [muted]: Indicates whether the audio will be initially silenced. Its default value is false.
/// - [preload]: Provides a hint to the browser about what the author thinks will lead to the best user experience.
/// - [src]: The URL of the audio to embed. This is subject to HTTP access controls. This is optional; you may instead use the &lt;source&gt; element within the audio block to specify the audio to embed.
Component audio({bool? autoplay, bool? controls, CrossOrigin? crossOrigin, bool? loop, bool? muted, Preload? preload, String? src, Key? key, String? id, Iterable<String>? classes, Map<String, String>? styles, Map<String, String>? attributes, Map<String, EventCallback>? events, Component? child, List<Component>? children}) {
  return DomComponent(
    tag: 'audio',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (autoplay == true) 'autoplay': '',
      if (controls == true) 'controls': '',
      if (crossOrigin != null) 'crossorigin': crossOrigin.value,
      if (loop == true) 'loop': '',
      if (muted == true) 'muted': '',
      if (preload != null) 'preload': preload.value,
      if (src != null) 'src': src,
    },
    events: events,
    child: child,
    children: children,
  );
}


/// Indicates if the fetching of the media must be done using a CORS request. Media data from a CORS request can be reused in the &lt;canvas&gt; element without being marked "tainted". If the crossorigin attribute is not specified, then a non-CORS request is sent (without the Origin request header), and the browser marks the media as tainted and restricts access to its data, preventing its usage in &lt;canvas&gt; elements. If the crossorigin attribute is specified, then a CORS request is sent (with the Origin request header); but if the server does not opt into allowing cross-origin access to the media data by the origin site (by not sending any Access-Control-Allow-Origin response header, or by not including the site's origin in any Access-Control-Allow-Origin response header it does send), then the browser blocks the media from loading, and logs a CORS error to the devtools console.
enum CrossOrigin {
  /// Sends a cross-origin request without a credential. In other words, it sends the Origin: HTTP header without a cookie, X.509 certificate, or performing HTTP Basic authentication. If the server does not give credentials to the origin site (by not setting the Access-Control-Allow-Origin: HTTP header), the image will be tainted, and its usage restricted.
  anonymous('anonymous'),
  /// Sends a cross-origin request with a credential. In other words, it sends the Origin: HTTP header with a cookie, a certificate, or performing HTTP Basic authentication. If the server does not give credentials to the origin site (through Access-Control-Allow-Credentials: HTTP header), the image will be tainted and its usage restricted.
  useCredentials('use-credentials');

  final String value;
  const CrossOrigin(this.value);
}


/// Intended to provide a hint to the browser about what the author thinks will lead to the best user experience when loading a media object.
/// The default value is different for each browser. The spec advises it to be set to [Preload.metadata].
enum Preload {
  /// Indicates that the audio should not be preloaded.
  none('none'),
  /// Indicates that only audio metadata (e.g. length) is fetched.
  metadata('metadata'),
  /// Indicates that the whole audio file can be downloaded, even if the user is not expected to use it.
  auto('auto');

  final String value;
  const Preload(this.value);
}

/// The &lt;img&gt; HTML element embeds an image into the document.
///
/// - [alt]: Defines an alternative text description of the image
/// - [crossOrigin]: Indicates if the fetching of the image must be done using a CORS request.
/// - [width]: The intrinsic width of the image in pixels.
/// - [height]: The intrinsic height of the image, in pixels.
/// - [loading]: Indicates how the browser should load the image.
/// - [src]: The image URL.
Component img({String? alt, CrossOrigin? crossOrigin, int? width, int? height, ImageLoading? loading, required String src, Key? key, String? id, Iterable<String>? classes, Map<String, String>? styles, Map<String, String>? attributes, Map<String, EventCallback>? events, Component? child, List<Component>? children}) {
  return DomComponent(
    tag: 'img',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (alt != null) 'alt': alt,
      if (crossOrigin != null) 'crossorigin': crossOrigin.value,
      if (width != null) 'width': '$width',
      if (height != null) 'height': '$height',
      if (loading != null) 'loading': loading.value,
      'src': src,
    },
    events: events,
    child: child,
    children: children,
  );
}


/// Indicates how the browser should load the image. Loading is only deferred when JavaScript is enabled.
enum ImageLoading {
  /// Loads the image immediately, regardless of whether or not the image is currently within the visible viewport (this is the default value).
  eager('eager'),
  /// Defers loading the image until it reaches a calculated distance from the viewport, as defined by the browser. The intent is to avoid the network and storage bandwidth needed to handle the image until it's reasonably certain that it will be needed. This generally improves the performance of the content in most typical use cases.
  lazy('lazy');

  final String value;
  const ImageLoading(this.value);
}

/// The &lt;video&gt; HTML element embeds a media player which supports video playback into the document. You can use &lt;video&gt; for audio content as well, but the &lt;audio&gt; element may provide a more appropriate user experience.
///
/// - [autoplay]: Indicates if the video automatically begins to play back as soon as it can do so without stopping to finish loading the data.
/// - [controls]: If this attribute is present, the browser will offer controls to allow the user to control video playback, including volume, seeking, and pause/resume playback.
/// - [crossOrigin]: Indicates whether to use CORS to fetch the related video.
/// - [loop]: If specified, the browser will automatically seek back to the start upon reaching the end of the video.
/// - [muted]: Indicates the default setting of the audio contained in the video. If set, the audio will be initially silenced. Its default value is false, meaning that the audio will be played when the video is played.
/// - [poster]: A URL for an image to be shown while the video is downloading. If this attribute isn't specified, nothing is displayed until the first frame is available, then the first frame is shown as the poster frame.
/// - [preload]: Provides a hint to the browser about what the author thinks will lead to the best user experience with regards to what content is loaded before the video is played.
/// - [src]: The URL of the video to embed. This is optional; you may instead use the &lt;source&gt; element within the video block to specify the video to embed.
/// - [width]: The width of the video's display area, in CSS pixels.
/// - [height]: The height of the video's display area, in CSS pixels.
Component video({bool? autoplay, bool? controls, CrossOrigin? crossOrigin, bool? loop, bool? muted, String? poster, Preload? preload, String? src, int? width, int? height, Key? key, String? id, Iterable<String>? classes, Map<String, String>? styles, Map<String, String>? attributes, Map<String, EventCallback>? events, Component? child, List<Component>? children}) {
  return DomComponent(
    tag: 'video',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (autoplay == true) 'autoplay': '',
      if (controls == true) 'controls': '',
      if (crossOrigin != null) 'crossorigin': crossOrigin.value,
      if (loop == true) 'loop': '',
      if (muted == true) 'muted': '',
      if (poster != null) 'poster': poster,
      if (preload != null) 'preload': preload.value,
      if (src != null) 'src': src,
      if (width != null) 'width': '$width',
      if (height != null) 'height': '$height',
    },
    events: events,
    child: child,
    children: children,
  );
}
