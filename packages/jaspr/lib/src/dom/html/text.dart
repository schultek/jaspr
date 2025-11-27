// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off
// ignore_for_file: camel_case_types

part of 'html.dart';

/// {@template jaspr.html.a}
/// The &lt;a&gt; HTML element (or anchor element), with its href attribute, creates a hyperlink to web pages, files, email addresses, locations in the same page, or anything else a URL can address.
///
/// Content within each &lt;a&gt; should indicate the link's destination. If the href attribute is present, pressing the enter key while focused on the &lt;a&gt; element will activate it.
/// {@endtemplate}
final class a extends StatelessComponent {
  /// {@macro jaspr.html.a}
  const a(
    this.children, {
    this.download,
    required this.href,
    this.target,
    this.type,
    this.referrerPolicy,
    this.onClick,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Causes the browser to treat the linked URL as a download. Can be used with or without a value:
  ///
  /// Without a value, the browser will suggest a filename/extension, generated from various sources:
  /// The Content-Disposition HTTP header
  /// The final segment in the URL path
  /// The media type (from the Content-Type header, the start of a data: URL, or Blob.type for a blob: URL)
  /// Defining a value suggests it as the filename. / and \ characters are converted to underscores (_). Filesystems may forbid other characters in filenames, so browsers will adjust the suggested name if necessary.
  final String? download;

  /// The URL that the hyperlink points to. Links are not restricted to HTTP-based URLs — they can use any URL scheme supported by browsers:
  ///
  /// Sections of a page with fragment URLs
  /// Pieces of media files with media fragments
  /// Telephone numbers with tel: URLs
  /// Email addresses with mailto: URLs
  /// While web browsers may not support other URL schemes, web sites can with registerProtocolHandler()
  final String href;

  /// Where to display the linked URL, as the name for a browsing context (a tab, window, or &lt;iframe&gt;).
  final Target? target;

  /// Hints at the linked URL's format with a MIME type. No built-in functionality.
  final String? type;

  /// How much of the referrer to send when following the link.
  final ReferrerPolicy? referrerPolicy;

  /// Callback for the 'click' event. This will override the default behavior of the link and not visit [href] when clicked.
  final VoidCallback? onClick;

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
      tag: 'a',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'download': ?download,
        'href': href,
        'target': ?target?.value,
        'type': ?type,
        'referrerpolicy': ?referrerPolicy?.value,
      },
      events: {
        ...?events,
        ..._events<void>(onClick: onClick),
      },
      children: children,
    );
  }
}

/// The name/keyword for a browsing context (a tab, window, or &lt;iframe&gt;).
enum Target {
  /// The current browsing context. (Default)
  self('_self'),

  /// Usually a new tab, but users can configure browsers to open a new window instead.
  blank('_blank'),

  /// The parent browsing context of the current one. If no parent, behaves as [Target.self].
  parent('_parent'),

  /// The topmost browsing context (the "highest" context that's an ancestor of the current one). If no ancestors, behaves as [Target.self].
  top('_top');

  const Target(this.value);

  final String value;
}

/// {@template jaspr.html.b}
/// The &lt;b&gt; HTML element is used to draw the reader's attention to the element's contents, which are not otherwise granted special importance. This was formerly known as the Boldface element, and most browsers still draw the text in boldface. However, you should not use &lt;b&gt; for styling text; instead, you should use the CSS font-weight property to create boldface text, or the &lt;strong&gt; element to indicate that text is of special importance.
/// {@endtemplate}
final class b extends StatelessComponent {
  /// {@macro jaspr.html.b}
  const b(
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
      tag: 'b',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.br}
/// The &lt;br&gt; HTML element produces a line break in text (carriage-return). It is useful for writing a poem or an address, where the division of lines is significant.
/// {@endtemplate}
final class br extends StatelessComponent {
  /// {@macro jaspr.html.br}
  const br({
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

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'br',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
    );
  }
}

/// {@template jaspr.html.code}
/// The &lt;code&gt; HTML element displays its contents styled in a fashion intended to indicate that the text is a short fragment of computer code. By default, the content text is displayed using the user agent's default monospace font.
/// {@endtemplate}
final class code extends StatelessComponent {
  /// {@macro jaspr.html.code}
  const code(
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
      tag: 'code',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.em}
/// The &lt;em&gt; HTML element marks text that has stress emphasis. The &lt;em&gt; element can be nested, with each level of nesting indicating a greater degree of emphasis.
/// {@endtemplate}
final class em extends StatelessComponent {
  /// {@macro jaspr.html.em}
  const em(
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
      tag: 'em',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.i}
/// The &lt;i&gt; HTML element represents a range of text that is set off from the normal text for some reason, such as idiomatic text, technical terms, taxonomical designations, among others. Historically, these have been presented using italicized type, which is the original source of the &lt;i&gt; naming of this element.
/// {@endtemplate}
final class i extends StatelessComponent {
  /// {@macro jaspr.html.i}
  const i(
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
      tag: 'i',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.s}
/// The &lt;s&gt; HTML element renders text with a strikethrough, or a line through it. Use the &lt;s&gt; element to represent things that are no longer relevant or no longer accurate. However, &lt;s&gt; is not appropriate when indicating document edits; for that, use the &lt;del&gt; and &lt;ins&gt; elements, as appropriate.
/// {@endtemplate}
final class s extends StatelessComponent {
  /// {@macro jaspr.html.s}
  const s(
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
      tag: 's',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.small}
/// The &lt;small&gt; HTML element represents side-comments and small print, like copyright and legal text, independent of its styled presentation. By default, it renders text within it one font-size smaller, such as from small to x-small.
/// {@endtemplate}
final class small extends StatelessComponent {
  /// {@macro jaspr.html.small}
  const small(
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
      tag: 'small',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.span}
/// The &lt;span&gt; HTML element is a generic inline container for phrasing content, which does not inherently represent anything. It can be used to group elements for styling purposes (using the class or id attributes), or because they share attribute values, such as lang. It should be used only when no other semantic element is appropriate. &lt;span&gt; is very much like a &lt;div&gt; element, but &lt;div&gt; is a block-level element whereas a &lt;span&gt; is an inline element.
/// {@endtemplate}
final class span extends StatelessComponent {
  /// {@macro jaspr.html.span}
  const span(
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
      tag: 'span',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.strong}
/// The &lt;strong&gt; HTML element indicates that its contents have strong importance, seriousness, or urgency. Browsers typically render the contents in bold type.
/// {@endtemplate}
final class strong extends StatelessComponent {
  /// {@macro jaspr.html.strong}
  const strong(
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
      tag: 'strong',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.u}
/// The &lt;u&gt; HTML element represents a span of inline text which should be rendered in a way that indicates that it has a non-textual annotation. This is rendered by default as a simple solid underline, but may be altered using CSS.
/// {@endtemplate}
final class u extends StatelessComponent {
  /// {@macro jaspr.html.u}
  const u(
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
      tag: 'u',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.wbr}
/// The &lt;wbr&gt; HTML element represents a word break opportunity—a position within text where the browser may optionally break a line, though its line-breaking rules would not otherwise create a break at that location.
/// {@endtemplate}
final class wbr extends StatelessComponent {
  /// {@macro jaspr.html.wbr}
  const wbr({
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

  @override
  Component build(BuildContext context) {
    return Component.element(
      tag: 'wbr',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
    );
  }
}
