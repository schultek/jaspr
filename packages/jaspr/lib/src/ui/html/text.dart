part of jaspr_html;

/// The &lt;a&gt; HTML element (or anchor element), with its href attribute, creates a hyperlink to web pages, files, email addresses, locations in the same page, or anything else a URL can address.
/// 
/// Content within each &lt;a&gt; should indicate the link's destination. If the href attribute is present, pressing the enter key while focused on the &lt;a&gt; element will activate it.
///
/// - [download]: Causes the browser to treat the linked URL as a download. Can be used with or without a value:
///   
///   Without a value, the browser will suggest a filename/extension, generated from various sources:
///   The Content-Disposition HTTP header
///   The final segment in the URL path
///   The media type (from the Content-Type header, the start of a data: URL, or Blob.type for a blob: URL)
///   Defining a value suggests it as the filename. / and \ characters are converted to underscores (_). Filesystems may forbid other characters in filenames, so browsers will adjust the suggested name if necessary.
/// - [href]: The URL that the hyperlink points to. Links are not restricted to HTTP-based URLs — they can use any URL scheme supported by browsers:
///   
///   Sections of a page with fragment URLs
///   Pieces of media files with media fragments
///   Telephone numbers with tel: URLs
///   Email addresses with mailto: URLs
///   While web browsers may not support other URL schemes, web sites can with registerProtocolHandler()
/// - [target]: Where to display the linked URL, as the name for a browsing context (a tab, window, or &lt;iframe&gt;).
/// - [type]: Hints at the linked URL's format with a MIME type. No built-in functionality.
/// - [referrerPolicy]: How much of the referrer to send when following the link.
Component a(List<Component> children, {String? download, required String href, Target? target, String? type, ReferrerPolicy? referrerPolicy, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'a',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (download != null) 'download': download,
      'href': href,
      if (target != null) 'target': target.value,
      if (type != null) 'type': type,
      if (referrerPolicy != null) 'referrerpolicy': referrerPolicy.value,
    },
    events: events,
    children: children,
  );
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

  final String value;
  const Target(this.value);
}

/// The &lt;b&gt; HTML element is used to draw the reader's attention to the element's contents, which are not otherwise granted special importance. This was formerly known as the Boldface element, and most browsers still draw the text in boldface. However, you should not use &lt;b&gt; for styling text; instead, you should use the CSS font-weight property to create boldface text, or the &lt;strong&gt; element to indicate that text is of special importance.
Component b(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'b',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;br&gt; HTML element produces a line break in text (carriage-return). It is useful for writing a poem or an address, where the division of lines is significant.
Component br({Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'br',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
  );
}

/// The &lt;code&gt; HTML element displays its contents styled in a fashion intended to indicate that the text is a short fragment of computer code. By default, the content text is displayed using the user agent's default monospace font.
Component code(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'code',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;em&gt; HTML element marks text that has stress emphasis. The &lt;em&gt; element can be nested, with each level of nesting indicating a greater degree of emphasis.
Component em(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'em',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;i&gt; HTML element represents a range of text that is set off from the normal text for some reason, such as idiomatic text, technical terms, taxonomical designations, among others. Historically, these have been presented using italicized type, which is the original source of the &lt;i&gt; naming of this element.
Component i(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'i',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;s&gt; HTML element renders text with a strikethrough, or a line through it. Use the &lt;s&gt; element to represent things that are no longer relevant or no longer accurate. However, &lt;s&gt; is not appropriate when indicating document edits; for that, use the &lt;del&gt; and &lt;ins&gt; elements, as appropriate.
Component s(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 's',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;small&gt; HTML element represents side-comments and small print, like copyright and legal text, independent of its styled presentation. By default, it renders text within it one font-size smaller, such as from small to x-small.
Component small(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'small',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;span&gt; HTML element is a generic inline container for phrasing content, which does not inherently represent anything. It can be used to group elements for styling purposes (using the class or id attributes), or because they share attribute values, such as lang. It should be used only when no other semantic element is appropriate. &lt;span&gt; is very much like a &lt;div&gt; element, but &lt;div&gt; is a block-level element whereas a &lt;span&gt; is an inline element.
Component span(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'span',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;strong&gt; HTML element indicates that its contents have strong importance, seriousness, or urgency. Browsers typically render the contents in bold type.
Component strong(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'strong',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;u&gt; HTML element represents a span of inline text which should be rendered in a way that indicates that it has a non-textual annotation. This is rendered by default as a simple solid underline, but may be altered using CSS.
Component u(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'u',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}
