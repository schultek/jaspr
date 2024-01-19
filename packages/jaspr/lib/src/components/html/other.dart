part of 'html.dart';

/// The &lt;details&gt; HTML element creates a disclosure widget in which information is visible only when the widget is toggled into an "open" state. A summary or label must be provided using the &lt;summary&gt; element.
///
/// - [open]: Indicates whether or not the details — that is, the contents of the &lt;details&gt; element — are currently visible.
Component details(List<Component> children,
    {bool? open,
    Key? key,
    String? id,
    List<String>? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'details',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (open == true) 'open': '',
    },
    events: events,
    children: children,
  );
}

/// The &lt;dialog&gt; HTML element represents a dialog box or other interactive component, such as a dismissible alert, inspector, or subwindow.
///
/// - [open]: Indicates that the dialog is active and can be interacted with. When the open attribute is not set, the dialog shouldn't be shown to the user.
Component dialog(List<Component> children,
    {bool? open,
    Key? key,
    String? id,
    List<String>? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'dialog',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (open == true) 'open': '',
    },
    events: events,
    children: children,
  );
}

/// The &lt;summary&gt; HTML element specifies a summary, caption, or legend for a &lt;details&gt; element's disclosure box. Clicking the &lt;summary&gt; element toggles the state of the parent &lt;details&gt; element open and closed.
Component summary(List<Component> children,
    {Key? key,
    String? id,
    List<String>? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'summary',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The <link> HTML element specifies relationships between the current document and an external resource. This element is most commonly used to link to stylesheets, but is also used to establish site icons (both "favicon" style icons and icons for the home screen and apps on mobile devices) among other things.
///
/// - [href]: This attribute specifies the URL of the linked resource. A URL can be absolute or relative.
/// - [rel]: This attribute names a relationship of the linked document to the current document. The attribute must be a space-separated list of link type values.
/// - [type]: This attribute is used to define the type of the content linked to. The value of the attribute should be a MIME type such as text/html, text/css, and so on. The common use of this attribute is to define the type of stylesheet being referenced (such as text/css), but given that CSS is the only stylesheet language used on the web, not only is it possible to omit the type attribute, but is actually now recommended practice. It is also used on rel="preload" link types, to make sure the browser only downloads file types that it supports.
/// - [as]: This attribute is only used when rel="preload" or rel="prefetch" has been set on the <link> element. It specifies the type of content being loaded by the <link>, which is necessary for request matching, application of correct content security policy, and setting of correct Accept request header. Furthermore, rel="preload" uses this as a signal for request prioritization.
Component link(
    {required String href,
    String? rel,
    String? type,
    String? as,
    Key? key,
    String? id,
    List<String>? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'link',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      'href': href,
      if (rel != null) 'rel': rel,
      if (type != null) 'type': type,
      if (as != null) 'as': as,
    },
    events: events,
  );
}

/// The <script> HTML element is used to embed executable code or data; this is typically used to embed or refer to JavaScript code. The <script> element can also be used with other languages, such as WebGL's GLSL shader programming language and JSON.
///
/// - [async]: For classic scripts, if the async attribute is present, then the classic script will be fetched in parallel to parsing and evaluated as soon as it is available.
///
///   For module scripts, if the async attribute is present then the scripts and all their dependencies will be executed in the defer queue, therefore they will get fetched in parallel to parsing and evaluated as soon as they are available.
///
///   This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse. defer has a similar effect in this case.
/// - [defer]: This Boolean attribute is set to indicate to a browser that the script is meant to be executed after the document has been parsed, but before firing DOMContentLoaded.
///
///   Scripts with the defer attribute will prevent the DOMContentLoaded event from firing until the script has loaded and finished evaluating.
///
///   Scripts with the defer attribute will execute in the order in which they appear in the document.
///
///   This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse. async has a similar effect in this case.
/// - [src]: This attribute specifies the URI of an external script; this can be used as an alternative to embedding a script directly within a document.
Component script(List<Component> children,
    {bool? async,
    bool? defer,
    required String src,
    Key? key,
    String? id,
    List<String>? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'script',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (async == true) 'async': '',
      if (defer == true) 'defer': '',
      'src': src,
    },
    events: events,
    children: children,
  );
}
