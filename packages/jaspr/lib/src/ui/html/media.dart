part of jaspr_html;

/// The &lt;audio&gt; HTML element is used to embed sound content in documents. It may contain one or more audio sources, represented using the src attribute or the &lt;source&gt; element: the browser will choose the most suitable one. It can also be the destination for streamed media, using a MediaStream.
///
/// - [autoplay]: A Boolean attribute: if specified, the audio will automatically begin playback as soon as it can do so, without waiting for the entire audio file to finish downloading.
/// - [controls]: If this attribute is present, the browser will offer controls to allow the user to control audio playback, including volume, seeking, and pause/resume playback.
/// - [crossOrigin]: Indicates whether to use CORS to fetch the related audio file.
/// - [loop]: If specified, the audio player will automatically seek back to the start upon reaching the end of the audio.
/// - [muted]: Indicates whether the audio will be initially silenced. Its default value is false.
/// - [preload]: Provides a hint to the browser about what the author thinks will lead to the best user experience.
/// - [src]: The URL of the audio to embed. This is subject to HTTP access controls. This is optional; you may instead use the &lt;source&gt; element within the audio block to specify the audio to embed.
Component audio(List<Component> children, {bool? autoplay, bool? controls, CrossOrigin? crossOrigin, bool? loop, bool? muted, Preload? preload, String? src, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
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
/// - [referrerPolicy]: Indicates which referrer to send when fetching the resource.
Component img({String? alt, CrossOrigin? crossOrigin, int? width, int? height, MediaLoading? loading, required String src, ReferrerPolicy? referrerPolicy, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
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
      if (referrerPolicy != null) 'referrerpolicy': referrerPolicy.value,
    },
    events: events,
  );
}

/// Indicates how the browser should load the media. Loading is only deferred when JavaScript is enabled.
enum MediaLoading {
  /// Loads the media immediately, regardless of whether or not the media is currently within the visible viewport (this is the default value).
  eager('eager'),
  /// Defers loading the media until it reaches a calculated distance from the viewport, as defined by the browser. The intent is to avoid the network and storage bandwidth needed to handle the media until it's reasonably certain that it will be needed. This generally improves the performance of the media in most typical use cases.
  lazy('lazy');

  final String value;
  const MediaLoading(this.value);
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
Component video(List<Component> children, {bool? autoplay, bool? controls, CrossOrigin? crossOrigin, bool? loop, bool? muted, String? poster, Preload? preload, String? src, int? width, int? height, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
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
    children: children,
  );
}

/// The &lt;embed&gt; HTML element embeds external content at the specified point in the document. This content is provided by an external application or other source of interactive content such as a browser plug-in.
///
/// - [src]: The URL of the resource being embedded.
/// - [type]: The MIME type to use to select the plug-in to instantiate.
/// - [width]: The displayed width of the resource, in CSS pixels.
/// - [height]: The displayed height of the resource, in CSS pixels.
Component embed({required String src, String? type, int? width, int? height, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'embed',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      'src': src,
      if (type != null) 'type': type,
      if (width != null) 'width': '$width',
      if (height != null) 'height': '$height',
    },
    events: events,
  );
}

/// The &lt;iframe&gt; HTML element represents a nested browsing context, embedding another HTML page into the current one.
///
/// - [src]: The URL of the page to embed. Use a value of about:blank to embed an empty page that conforms to the same-origin policy. Also note that programmatically removing an &lt;iframe&gt;'s src attribute (e.g. via Element.removeAttribute()) causes about:blank to be loaded in the frame in Firefox (from version 65), Chromium-based browsers, and Safari/iOS.
/// - [allow]: Specifies a feature policy for the &lt;iframe&gt;. The policy defines what features are available to the &lt;iframe&gt; based on the origin of the request (e.g. access to the microphone, camera, battery, web-share API, etc.).
/// - [csp]: A Content Security Policy enforced for the embedded resource.
/// - [loading]: Indicates how the browser should load the iframe.
/// - [name]: A targetable name for the embedded browsing context. This can be used in the target attribute of the &lt;a&gt;, &lt;form&gt;, or &lt;base&gt; elements; the formtarget attribute of the &lt;input&gt; or &lt;button&gt; elements; or the windowName parameter in the window.open() method.
/// - [sandbox]: Applies extra restrictions to the content in the frame. The value of the attribute can either be empty to apply all restrictions, or space-separated tokens to lift particular restrictions.
/// - [referrerPolicy]: Indicates which referrer to send when fetching the frame's resource.
/// - [width]: The width of the frame in CSS pixels. Default is 300.
/// - [height]: The height of the frame in CSS pixels. Default is 150.
Component iframe(List<Component> children, {required String src, String? allow, String? csp, MediaLoading? loading, String? name, String? sandbox, ReferrerPolicy? referrerPolicy, int? width, int? height, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'iframe',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      'src': src,
      if (allow != null) 'allow': allow,
      if (csp != null) 'csp': csp,
      if (loading != null) 'loading': loading.value,
      if (name != null) 'name': name,
      if (sandbox != null) 'sandbox': sandbox,
      if (referrerPolicy != null) 'referrerpolicy': referrerPolicy.value,
      if (width != null) 'width': '$width',
      if (height != null) 'height': '$height',
    },
    events: events,
    children: children,
  );
}

/// The Referrer-Policy controls how much referrer information (sent with the Referer header) should be included with requests.
enum ReferrerPolicy {
  /// The Referer header will not be sent.
  noReferrer('no-referrer'),
  /// The Referer header will not be sent to origins without TLS (HTTPS).
  noReferrerWhenDowngrade('no-referrer-when-downgrade'),
  /// The sent referrer will be limited to the origin of the referring page: its scheme, host, and port.
  origin('origin'),
  /// The referrer sent to other origins will be limited to the scheme, the host, and the port. Navigations on the same origin will still include the path.
  originWhenCrossOrigin('origin-when-cross-origin'),
  /// A referrer will be sent for same origin, but cross-origin requests will contain no referrer information.
  sameOrigin('same-origin'),
  /// Only send the origin of the document as the referrer when the protocol security level stays the same (HTTPS→HTTPS), but don't send it to a less secure destination (HTTPS→HTTP).
  strictOrigin('strict-origin'),
  /// (default): Send a full URL when performing a same-origin request, only send the origin when the protocol security level stays the same (HTTPS→HTTPS), and send no header to a less secure destination (HTTPS→HTTP).
  strictOriginWhenCrossOrigin('strict-origin-when-cross-origin'),
  /// The referrer will include the origin and the path (but not the fragment, password, or username). This value is unsafe, because it leaks origins and paths from TLS-protected resources to insecure origins.
  unsafeUrl('unsafe-url');

  final String value;
  const ReferrerPolicy(this.value);
}

/// The &lt;object&gt; HTML element represents an external resource, which can be treated as an image, a nested browsing context, or a resource to be handled by a plugin.
///
/// - [data]: The address of the resource as a valid URL. At least one of data and type must be defined.
/// - [name]: The name of valid browsing context (HTML5).
/// - [type]: The content type of the resource specified by data. At least one of data and type must be defined.
/// - [width]: The width of the displayed resource in CSS pixels.
/// - [height]: The height of the displayed resource in CSS pixels.
Component object(List<Component> children, {String? data, String? name, String? type, int? width, int? height, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'object',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (data != null) 'data': data,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (width != null) 'width': '$width',
      if (height != null) 'height': '$height',
    },
    events: events,
    children: children,
  );
}

/// The &lt;source&gt; HTML element specifies multiple media resources for the &lt;picture&gt;, the &lt;audio&gt; element, or the &lt;video&gt; element. It is an empty element, meaning that it has no content and does not have a closing tag. It is commonly used to offer the same media content in multiple file formats in order to provide compatibility with a broad range of browsers given their differing support for image file formats and media file formats.
///
/// - [type]: The MIME media type of the resource, optionally with a codecs parameter.
/// - [src]: Address of the media resource.
///   
///   Required if the source element's parent is an &lt;audio&gt; and &lt;video&gt; element, but not allowed if the source element's parent is a &lt;picture&gt; element.
Component source({String? type, String? src, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'source',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (type != null) 'type': type,
      if (src != null) 'src': src,
    },
    events: events,
  );
}
