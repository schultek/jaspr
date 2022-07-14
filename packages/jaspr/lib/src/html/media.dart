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

enum CrossOrigin {
  anonymous('anonymous'), useCredentials('use-credentials')
}

enum Preload {
  none('none'), metadata('metadata'), auto('auto')
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

enum ImageLoading {
  eager('eager'), lazy('lazy')
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
