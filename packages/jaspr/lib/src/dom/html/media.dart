// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off
// ignore_for_file: camel_case_types

part of 'html.dart';

/// {@template jaspr.html.audio}
/// The &lt;audio&gt; HTML element is used to embed sound content in documents. It may contain one or more audio sources, represented using the src attribute or the &lt;source&gt; element: the browser will choose the most suitable one. It can also be the destination for streamed media, using a MediaStream.
/// {@endtemplate}
final class audio extends StatelessComponent {
  /// {@macro jaspr.html.audio}
  const audio(
    this.children, {
    this.autoplay = false,
    this.controls = false,
    this.crossOrigin,
    this.loop = false,
    this.muted = false,
    this.preload,
    this.src,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// A Boolean attribute: if specified, the audio will automatically begin playback as soon as it can do so, without waiting for the entire audio file to finish downloading.
  final bool autoplay;

  /// If this attribute is present, the browser will offer controls to allow the user to control audio playback, including volume, seeking, and pause/resume playback.
  final bool controls;

  /// Indicates whether to use CORS to fetch the related audio file.
  final CrossOrigin? crossOrigin;

  /// If specified, the audio player will automatically seek back to the start upon reaching the end of the audio.
  final bool loop;

  /// Indicates whether the audio will be initially silenced. Its default value is false.
  final bool muted;

  /// Provides a hint to the browser about what the author thinks will lead to the best user experience.
  final Preload? preload;

  /// The URL of the audio to embed. This is subject to HTTP access controls. This is optional; you may instead use the &lt;source&gt; element within the audio block to specify the audio to embed.
  final String? src;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'audio',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        if (autoplay) 'autoplay': '',
        if (controls) 'controls': '',
        'crossorigin': ?crossOrigin?.value,
        if (loop) 'loop': '',
        if (muted) 'muted': '',
        'preload': ?preload?.value,
        'src': ?src,
      },
      events: events,
      children: children,
    );
  }
}

/// Indicates if the fetching of the media must be done using a CORS request. Media data from a CORS request can be reused in the &lt;canvas&gt; element without being marked "tainted". If the crossorigin attribute is not specified, then a non-CORS request is sent (without the Origin request header), and the browser marks the media as tainted and restricts access to its data, preventing its usage in &lt;canvas&gt; elements. If the crossorigin attribute is specified, then a CORS request is sent (with the Origin request header); but if the server does not opt into allowing cross-origin access to the media data by the origin site (by not sending any Access-Control-Allow-Origin response header, or by not including the site's origin in any Access-Control-Allow-Origin response header it does send), then the browser blocks the media from loading, and logs a CORS error to the devtools console.
enum CrossOrigin {
  /// Sends a cross-origin request without a credential. In other words, it sends the Origin: HTTP header without a cookie, X.509 certificate, or performing HTTP Basic authentication. If the server does not give credentials to the origin site (by not setting the Access-Control-Allow-Origin: HTTP header), the image will be tainted, and its usage restricted.
  anonymous('anonymous'),

  /// Sends a cross-origin request with a credential. In other words, it sends the Origin: HTTP header with a cookie, a certificate, or performing HTTP Basic authentication. If the server does not give credentials to the origin site (through Access-Control-Allow-Credentials: HTTP header), the image will be tainted and its usage restricted.
  useCredentials('use-credentials');

  const CrossOrigin(this.value);

  final String value;
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

  const Preload(this.value);

  final String value;
}

/// {@template jaspr.html.img}
/// The &lt;img&gt; HTML element embeds an image into the document.
/// {@endtemplate}
final class img extends StatelessComponent {
  /// {@macro jaspr.html.img}
  const img({
    this.alt,
    this.crossOrigin,
    this.width,
    this.height,
    this.loading,
    required this.src,
    this.referrerPolicy,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Defines an alternative text description of the image
  final String? alt;

  /// Indicates if the fetching of the image must be done using a CORS request.
  final CrossOrigin? crossOrigin;

  /// The intrinsic width of the image in pixels.
  final int? width;

  /// The intrinsic height of the image, in pixels.
  final int? height;

  /// Indicates how the browser should load the image.
  final MediaLoading? loading;

  /// The image URL.
  final String src;

  /// Indicates which referrer to send when fetching the resource.
  final ReferrerPolicy? referrerPolicy;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'img',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'alt': ?alt,
        'crossorigin': ?crossOrigin?.value,
        'width': ?width?.toString(),
        'height': ?height?.toString(),
        'loading': ?loading?.value,
        'src': src,
        'referrerpolicy': ?referrerPolicy?.value,
      },
      events: events,
    );
  }
}

/// Indicates how the browser should load the media. Loading is only deferred when JavaScript is enabled.
enum MediaLoading {
  /// Loads the media immediately, regardless of whether or not the media is currently within the visible viewport (this is the default value).
  eager('eager'),

  /// Defers loading the media until it reaches a calculated distance from the viewport, as defined by the browser. The intent is to avoid the network and storage bandwidth needed to handle the media until it's reasonably certain that it will be needed. This generally improves the performance of the media in most typical use cases.
  lazy('lazy');

  const MediaLoading(this.value);

  final String value;
}

/// {@template jaspr.html.video}
/// The &lt;video&gt; HTML element embeds a media player which supports video playback into the document. You can use &lt;video&gt; for audio content as well, but the &lt;audio&gt; element may provide a more appropriate user experience.
/// {@endtemplate}
final class video extends StatelessComponent {
  /// {@macro jaspr.html.video}
  const video(
    this.children, {
    this.autoplay = false,
    this.controls = false,
    this.crossOrigin,
    this.loop = false,
    this.muted = false,
    this.poster,
    this.preload,
    this.src,
    this.width,
    this.height,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Indicates if the video automatically begins to play back as soon as it can do so without stopping to finish loading the data.
  final bool autoplay;

  /// If this attribute is present, the browser will offer controls to allow the user to control video playback, including volume, seeking, and pause/resume playback.
  final bool controls;

  /// Indicates whether to use CORS to fetch the related video.
  final CrossOrigin? crossOrigin;

  /// If specified, the browser will automatically seek back to the start upon reaching the end of the video.
  final bool loop;

  /// Indicates the default setting of the audio contained in the video. If set, the audio will be initially silenced. Its default value is false, meaning that the audio will be played when the video is played.
  final bool muted;

  /// A URL for an image to be shown while the video is downloading. If this attribute isn't specified, nothing is displayed until the first frame is available, then the first frame is shown as the poster frame.
  final String? poster;

  /// Provides a hint to the browser about what the author thinks will lead to the best user experience with regards to what content is loaded before the video is played.
  final Preload? preload;

  /// The URL of the video to embed. This is optional; you may instead use the &lt;source&gt; element within the video block to specify the video to embed.
  final String? src;

  /// The width of the video's display area, in CSS pixels.
  final int? width;

  /// The height of the video's display area, in CSS pixels.
  final int? height;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'video',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        if (autoplay) 'autoplay': '',
        if (controls) 'controls': '',
        'crossorigin': ?crossOrigin?.value,
        if (loop) 'loop': '',
        if (muted) 'muted': '',
        'poster': ?poster,
        'preload': ?preload?.value,
        'src': ?src,
        'width': ?width?.toString(),
        'height': ?height?.toString(),
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.embed}
/// The &lt;embed&gt; HTML element embeds external content at the specified point in the document. This content is provided by an external application or other source of interactive content such as a browser plug-in.
/// {@endtemplate}
final class embed extends StatelessComponent {
  /// {@macro jaspr.html.embed}
  const embed({
    required this.src,
    this.type,
    this.width,
    this.height,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The URL of the resource being embedded.
  final String src;

  /// The MIME type to use to select the plug-in to instantiate.
  final String? type;

  /// The displayed width of the resource, in CSS pixels.
  final int? width;

  /// The displayed height of the resource, in CSS pixels.
  final int? height;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'embed',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'src': src,
        'type': ?type,
        'width': ?width?.toString(),
        'height': ?height?.toString(),
      },
      events: events,
    );
  }
}

/// {@template jaspr.html.iframe}
/// The &lt;iframe&gt; HTML element represents a nested browsing context, embedding another HTML page into the current one.
/// {@endtemplate}
final class iframe extends StatelessComponent {
  /// {@macro jaspr.html.iframe}
  const iframe(
    this.children, {
    required this.src,
    this.allow,
    this.csp,
    this.loading,
    this.name,
    this.sandbox,
    this.referrerPolicy,
    this.width,
    this.height,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The URL of the page to embed. Use a value of about:blank to embed an empty page that conforms to the same-origin policy. Also note that programmatically removing an &lt;iframe&gt;'s src attribute (e.g. via Element.removeAttribute()) causes about:blank to be loaded in the frame in Firefox (from version 65), Chromium-based browsers, and Safari/iOS.
  final String src;

  /// Specifies a feature policy for the &lt;iframe&gt;. The policy defines what features are available to the &lt;iframe&gt; based on the origin of the request (e.g. access to the microphone, camera, battery, web-share API, etc.).
  final String? allow;

  /// A Content Security Policy enforced for the embedded resource.
  final String? csp;

  /// Indicates how the browser should load the iframe.
  final MediaLoading? loading;

  /// A targetable name for the embedded browsing context. This can be used in the target attribute of the &lt;a&gt;, &lt;form&gt;, or &lt;base&gt; elements; the formtarget attribute of the &lt;input&gt; or &lt;button&gt; elements; or the windowName parameter in the window.open() method.
  final String? name;

  /// Applies extra restrictions to the content in the frame. The value of the attribute can either be empty to apply all restrictions, or space-separated tokens to lift particular restrictions.
  final String? sandbox;

  /// Indicates which referrer to send when fetching the frame's resource.
  final ReferrerPolicy? referrerPolicy;

  /// The width of the frame in CSS pixels. Default is 300.
  final int? width;

  /// The height of the frame in CSS pixels. Default is 150.
  final int? height;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'iframe',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'src': src,
        'allow': ?allow,
        'csp': ?csp,
        'loading': ?loading?.value,
        'name': ?name,
        'sandbox': ?sandbox,
        'referrerpolicy': ?referrerPolicy?.value,
        'width': ?width?.toString(),
        'height': ?height?.toString(),
      },
      events: events,
      children: children,
    );
  }
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

  const ReferrerPolicy(this.value);

  final String value;
}

/// {@template jaspr.html.object}
/// The &lt;object&gt; HTML element represents an external resource, which can be treated as an image, a nested browsing context, or a resource to be handled by a plugin.
/// {@endtemplate}
final class object extends StatelessComponent {
  /// {@macro jaspr.html.object}
  const object(
    this.children, {
    this.data,
    this.name,
    this.type,
    this.width,
    this.height,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The address of the resource as a valid URL. At least one of data and type must be defined.
  final String? data;

  /// The name of valid browsing context (HTML5).
  final String? name;

  /// The content type of the resource specified by data. At least one of data and type must be defined.
  final String? type;

  /// The width of the displayed resource in CSS pixels.
  final int? width;

  /// The height of the displayed resource in CSS pixels.
  final int? height;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'object',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'data': ?data,
        'name': ?name,
        'type': ?type,
        'width': ?width?.toString(),
        'height': ?height?.toString(),
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.source}
/// The &lt;source&gt; HTML element specifies multiple media resources for the &lt;picture&gt;, the &lt;audio&gt; element, or the &lt;video&gt; element. It is an empty element, meaning that it has no content and does not have a closing tag. It is commonly used to offer the same media content in multiple file formats in order to provide compatibility with a broad range of browsers given their differing support for image file formats and media file formats.
/// {@endtemplate}
final class source extends StatelessComponent {
  /// {@macro jaspr.html.source}
  const source({
    this.type,
    this.src,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The MIME media type of the resource, optionally with a codecs parameter.
  final String? type;

  /// Address of the media resource.
  ///
  /// Required if the source element's parent is an &lt;audio&gt; and &lt;video&gt; element, but not allowed if the source element's parent is a &lt;picture&gt; element.
  final String? src;

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'source',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, 'type': ?type, 'src': ?src},
      events: events,
    );
  }
}

/// {@template jaspr.html.figure}
/// The &lt;figure&gt; HTML element represents self-contained content, potentially with an optional caption, which is specified using the &lt;figcaption&gt; element. The figure, its caption, and its contents are referenced as a single unit.
/// {@endtemplate}
final class figure extends StatelessComponent {
  /// {@macro jaspr.html.figure}
  const figure(
    this.children, {
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'figure',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.figcaption}
/// The &lt;figcaption&gt; HTML element represents a caption or legend describing the rest of the contents of its parent &lt;figure&gt; element, providing the &lt;figure&gt;> an accessible description.
/// {@endtemplate}
final class figcaption extends StatelessComponent {
  /// {@macro jaspr.html.figcaption}
  const figcaption(
    this.children, {
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The id of the HTML element. Must be unique within the document.
  final String? id;

  /// The CSS classes to apply to the HTML element, separated by whitespace.
  final String? classes;

  /// The inline styles to apply to the HTML element.
  final Styles? styles;

  /// Additional attributes to apply to the HTML element.
  final Map<String, String>? attributes;

  /// Event listeners to attach to the HTML element.
  final Map<String, EventCallback>? events;

  /// The children of this component.
  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'figcaption',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}
