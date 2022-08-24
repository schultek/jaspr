part of jaspr_html;

/// The &lt;article&gt; HTML element represents a self-contained composition in a document, page, application, or site, which is intended to be independently distributable or reusable (e.g., in syndication). Examples include: a forum post, a magazine or newspaper article, or a blog entry, a product card, a user-submitted comment, an interactive widget or gadget, or any other independent item of content.
Component article(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'article',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;aside&gt; HTML element represents a portion of a document whose content is only indirectly related to the document's main content. Asides are frequently presented as sidebars or call-out boxes.
Component aside(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'aside',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;footer&gt; HTML element represents a footer for its nearest ancestor sectioning content or sectioning root element. A &lt;footer&gt; typically contains information about the author of the section, copyright data or links to related documents.
Component footer(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'footer',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;header&gt; HTML element represents introductory content, typically a group of introductory or navigational aids. It may contain some heading elements but also a logo, a search form, an author name, and other elements.
Component header(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'header',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;h1&gt; to &lt;h6&gt; HTML elements represent six levels of section headings. &lt;h1&gt; is the highest section level and &lt;h6&gt; is the lowest.
Component h1(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'h1',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;h1&gt; to &lt;h6&gt; HTML elements represent six levels of section headings. &lt;h1&gt; is the highest section level and &lt;h6&gt; is the lowest.
Component h2(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'h2',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;h1&gt; to &lt;h6&gt; HTML elements represent six levels of section headings. &lt;h1&gt; is the highest section level and &lt;h6&gt; is the lowest.
Component h3(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'h3',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;h1&gt; to &lt;h6&gt; HTML elements represent six levels of section headings. &lt;h1&gt; is the highest section level and &lt;h6&gt; is the lowest.
Component h4(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'h4',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;h1&gt; to &lt;h6&gt; HTML elements represent six levels of section headings. &lt;h1&gt; is the highest section level and &lt;h6&gt; is the lowest.
Component h5(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'h5',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;h1&gt; to &lt;h6&gt; HTML elements represent six levels of section headings. &lt;h1&gt; is the highest section level and &lt;h6&gt; is the lowest.
Component h6(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'h6',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;nav&gt; HTML element represents a section of a page whose purpose is to provide navigation links, either within the current document or to other documents. Common examples of navigation sections are menus, tables of contents, and indexes.
Component nav(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'nav',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;section&gt; HTML element represents a generic standalone section of a document, which doesn't have a more specific semantic element to represent it. Sections should always have a heading, with very few exceptions.
Component section(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'section',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;blockquote&gt; HTML element indicates that the enclosed text is an extended quotation. Usually, this is rendered visually by indentation. A URL for the source of the quotation may be given using the cite attribute, while a text representation of the source can be given using the &lt;cite&gt; element.
///
/// - [cite]: A URL that designates a source document or message for the information quoted. This attribute is intended to point to information explaining the context or the reference for the quote.
Component blockquote(List<Component> children, {String? cite, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'blockquote',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (cite != null) 'cite': cite,
    },
    events: events,
    children: children,
  );
}

/// The &lt;div&gt; HTML element is the generic container for flow content. It has no effect on the content or layout until styled in some way using CSS (e.g. styling is directly applied to it, or some kind of layout model like Flexbox is applied to its parent element).
Component div(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'div',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;ul&gt; HTML element represents an unordered list of items, typically rendered as a bulleted list.
Component ul(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'ul',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;ol&gt; HTML element represents an ordered list of items — typically rendered as a numbered list.
///
/// - [reversed]: This Boolean attribute specifies that the list's items are in reverse order. Items will be numbered from high to low.
/// - [start]: An integer to start counting from for the list items. Always an Arabic numeral (1, 2, 3, etc.), even when the numbering type is letters or Roman numerals. For example, to start numbering elements from the letter "d" or the Roman numeral "iv," use start="4".
/// - [type]: Sets the numbering type
///   The specified type is used for the entire list unless a different type attribute is used on an enclosed &lt;li&gt; element.
Component ol(List<Component> children, {bool? reversed, int? start, ListType? type, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'ol',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (reversed == true) 'reversed': '',
      if (start != null) 'start': '$start',
      if (type != null) 'type': type.value,
    },
    events: events,
    children: children,
  );
}

/// Them numbering type for a list element.
enum ListType {
  /// For lowercase letters
  lowercaseLetters('a'),
  /// For uppercase letters
  uppercaseLetters('A'),
  /// For lowercase Roman numerals
  lowercaseRomanNumerals('i'),
  /// For uppercase Roman numerals
  uppercaseRomanNumerals('I'),
  /// For numbers (default)
  numbers('1');

  final String value;
  const ListType(this.value);
}

/// The &lt;li&gt; HTML element is used to represent an item in a list. It must be contained in a parent element: an ordered list (&lt;ol&gt;), an unordered list (&lt;ul&gt;), or a menu (&lt;menu&gt;). In menus and unordered lists, list items are usually displayed using bullet points. In ordered lists, they are usually displayed with an ascending counter on the left, such as a number or letter.
///
/// - [value]: This integer attribute indicates the current ordinal value of the list item as defined by the &lt;ol&gt; element. The only allowed value for this attribute is a number, even if the list is displayed with Roman numerals or letters. List items that follow this one continue numbering from the value set. The value attribute has no meaning for unordered lists (&lt;ul&gt;) or for menus (&lt;menu&gt;).
Component li(List<Component> children, {int? value, Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'li',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...attributes ?? {},
      if (value != null) 'value': '$value',
    },
    events: events,
    children: children,
  );
}

/// The &lt;hr&gt; HTML element represents a thematic break between paragraph-level elements: for example, a change of scene in a story, or a shift of topic within a section.
Component hr({Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'hr',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
  );
}

/// The &lt;p&gt; HTML element represents a paragraph. Paragraphs are usually represented in visual media as blocks of text separated from adjacent blocks by blank lines and/or first-line indentation, but HTML paragraphs can be any structural grouping of related content, such as images or form fields.
Component p(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'p',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;pre&gt; HTML element represents preformatted text which is to be presented exactly as written in the HTML file. The text is typically rendered using a non-proportional, or monospaced, font. Whitespace inside this element is displayed as written.
Component pre(List<Component> children, {Key? key, String? id, List<String>? classes, Styles? styles, Map<String, String>? attributes, Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'pre',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}
