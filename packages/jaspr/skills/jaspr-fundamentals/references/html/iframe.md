# iframe

Signature of the iframe component:

```dart
const iframe(List<Component> children, {
  /// The URL of the page to embed. Use a value of about:blank to embed an empty page that conforms to the same-origin policy. Also note that programmatically removing an <iframe>'s src attribute (e.g. via Element.removeAttribute()) causes about:blank to be loaded in the frame in Firefox (from version 65), Chromium-based browsers, and Safari/iOS.
  required String src,
  /// Specifies a feature policy for the <iframe>. The policy defines what features are available to the <iframe> based on the origin of the request (e.g. access to the microphone, camera, battery, web-share API, etc.).
  String? allow,
  /// A Content Security Policy enforced for the embedded resource.
  String? csp,
  /// Indicates how the browser should load the iframe.
  MediaLoading? loading, // One of `.eager`, `.lazy`
  /// A targetable name for the embedded browsing context. This can be used in the target attribute of the <a>, <form>, or <base> elements; the formtarget attribute of the <input> or <button> elements; or the windowName parameter in the window.open() method.
  String? name,
  /// Applies extra restrictions to the content in the frame. The value of the attribute can either be empty to apply all restrictions, or space-separated tokens to lift particular restrictions.
  String? sandbox,
  /// Indicates which referrer to send when fetching the frame's resource.
  ReferrerPolicy? referrerPolicy, // One of `.noReferrer`, `.noReferrerWhenDowngrade`, `.origin`, `.originWhenCrossOrigin`, `.sameOrigin`, `.strictOrigin`, `.strictOriginWhenCrossOrigin`, `.unsafeUrl`
  /// The width of the frame in CSS pixels. Default is 300.
  int? width,
  /// The height of the frame in CSS pixels. Default is 150.
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
iframe(src: '...', [
  // ...
])
```