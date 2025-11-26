// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off
// ignore_for_file: camel_case_types

part of 'html.dart';

/// {@template jaspr.html.details}
/// The &lt;details&gt; HTML element creates a disclosure widget in which information is visible only when the widget is toggled into an "open" state. A summary or label must be provided using the &lt;summary&gt; element.
/// {@endtemplate}
final class details extends StatelessComponent {
  /// {@macro jaspr.html.details}
  const details(
    this.children, {
    this.open = false,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Indicates whether or not the details — that is, the contents of the &lt;details&gt; element — are currently visible.
  final bool open;

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
      tag: 'details',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, if (open) 'open': ''},
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.dialog}
/// The &lt;dialog&gt; HTML element represents a dialog box or other interactive component, such as a dismissible alert, inspector, or subwindow.
/// {@endtemplate}
final class dialog extends StatelessComponent {
  /// {@macro jaspr.html.dialog}
  const dialog(
    this.children, {
    this.open = false,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Indicates that the dialog is active and can be interacted with. When the open attribute is not set, the dialog shouldn't be shown to the user.
  final bool open;

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
      tag: 'dialog',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, if (open) 'open': ''},
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.summary}
/// The &lt;summary&gt; HTML element specifies a summary, caption, or legend for a &lt;details&gt; element's disclosure box. Clicking the &lt;summary&gt; element toggles the state of the parent &lt;details&gt; element open and closed.
/// {@endtemplate}
final class summary extends StatelessComponent {
  /// {@macro jaspr.html.summary}
  const summary(
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
      tag: 'summary',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.meta}
/// The  &lt;meta&gt; HTML element represents metadata that cannot be represented by other HTML meta-related elements, like  &lt;base &gt;,  &lt;link &gt;,  &lt;script &gt;,  &lt;style &gt; or  &lt;title &gt;.
/// {@endtemplate}
final class meta extends StatelessComponent {
  /// {@macro jaspr.html.meta}
  const meta({
    this.name,
    this.content,
    this.charset,
    this.httpEquiv,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// The name and content attributes can be used together to provide document metadata in terms of name-value pairs, with the name attribute giving the metadata name, and the content attribute giving the value.
  /// See standard metadata names for details about the set of standard metadata names defined in the HTML specification.
  final String? name;

  /// This attribute contains the value for the 'http-equiv' or 'name' attribute, depending on which is used.
  final String? content;

  /// This attribute declares the document's character encoding. If the attribute is present, its value must be an ASCII case-insensitive match for the string "utf-8", because UTF-8 is the only valid encoding for HTML5 documents. &lt;meta&gt; elements which declare a character encoding must be located entirely within the first 1024 bytes of the document.
  final String? charset;

  /// Defines a pragma directive. The attribute's name, short for http-equivalent, is because all the allowed values are names of particular HTTP headers.
  final String? httpEquiv;

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
      tag: 'meta',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'name': ?name,
        'content': ?content,
        'charset': ?charset,
        'http-equiv': ?httpEquiv,
      },
      events: events,
    );
  }
}

/// {@template jaspr.html.link}
/// The &lt;link&gt; HTML element specifies relationships between the current document and an external resource. This element is most commonly used to link to stylesheets, but is also used to establish site icons (both "favicon" style icons and icons for the home screen and apps on mobile devices) among other things.
/// {@endtemplate}
final class link extends StatelessComponent {
  /// {@macro jaspr.html.link}
  const link({
    required this.href,
    this.rel,
    this.type,
    this.as,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// This attribute specifies the URL of the linked resource. A URL can be absolute or relative.
  final String href;

  /// This attribute names a relationship of the linked document to the current document. The attribute must be a space-separated list of link type values.
  final String? rel;

  /// This attribute is used to define the type of the content linked to. The value of the attribute should be a MIME type such as text/html, text/css, and so on. The common use of this attribute is to define the type of stylesheet being referenced (such as text/css), but given that CSS is the only stylesheet language used on the web, not only is it possible to omit the type attribute, but is actually now recommended practice. It is also used on rel="preload" link types, to make sure the browser only downloads file types that it supports.
  final String? type;

  /// This attribute is only used when rel="preload" or rel="prefetch" has been set on the &lt;link&gt; element. It specifies the type of content being loaded by the &lt;link&gt;, which is necessary for request matching, application of correct content security policy, and setting of correct Accept request header. Furthermore, rel="preload" uses this as a signal for request prioritization.
  final String? as;

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
      tag: 'link',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'href': href,
        'rel': ?rel,
        'type': ?type,
        'as': ?as,
      },
      events: events,
    );
  }
}

/// {@template jaspr.html.script}
/// The &lt;script&gt; HTML element is used to embed executable code or data; this is typically used to embed or refer to JavaScript code. The &lt;script&gt; element can also be used with other languages, such as WebGL's GLSL shader programming language and JSON.
/// {@endtemplate}
final class script extends StatelessComponent {
  /// {@macro jaspr.html.script}
  const script({
    this.async = false,
    this.defer = false,
    this.src,
    this.content,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// For classic scripts, if the async attribute is present, then the classic script will be fetched in parallel to parsing and evaluated as soon as it is available.
  ///
  /// For module scripts, if the async attribute is present then the scripts and all their dependencies will be executed in the defer queue, therefore they will get fetched in parallel to parsing and evaluated as soon as they are available.
  ///
  /// This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse. defer has a similar effect in this case.
  final bool async;

  /// This Boolean attribute is set to indicate to a browser that the script is meant to be executed after the document has been parsed, but before firing DOMContentLoaded.
  ///
  /// Scripts with the defer attribute will prevent the DOMContentLoaded event from firing until the script has loaded and finished evaluating.
  ///
  /// Scripts with the defer attribute will execute in the order in which they appear in the document.
  ///
  /// This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse. async has a similar effect in this case.
  final bool defer;

  /// This attribute specifies the URI of an external script; this can be used as an alternative to embedding a script directly within a document.
  final String? src;

  /// The content of the script element, if it is not an external script.
  final String? content;

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
      tag: 'script',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        if (async) 'async': '',
        if (defer) 'defer': '',
        'src': ?src,
      },
      events: events,
      children: [if (content case final content?) RawText(content)],
    );
  }
}
