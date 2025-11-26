// GENERATED FILE - DO NOT EDIT
// Generated from packages/jaspr/tool/generate_html.dart
//
// dart format off
// ignore_for_file: camel_case_types

part of 'html.dart';

/// {@template jaspr.html.table}
/// The &lt;table&gt; HTML element represents tabular data—that is, information presented in a two-dimensional table comprised of rows and columns of cells containing data.
/// {@endtemplate}
final class table extends StatelessComponent {
  /// {@macro jaspr.html.table}
  const table(
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
      tag: 'table',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.caption}
/// The &lt;caption&gt; HTML element specifies the caption (or title) of a table, providing the table an accessible description.
/// {@endtemplate}
final class caption extends StatelessComponent {
  /// {@macro jaspr.html.caption}
  const caption(
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
      tag: 'caption',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.thead}
/// The &lt;thead&gt; HTML element encapsulates a set of table rows (&lt;tr&gt; elements), indicating that they comprise the head of a table with information about the table's columns. This is usually in the form of column headers (&lt;th&gt; elements).
/// {@endtemplate}
final class thead extends StatelessComponent {
  /// {@macro jaspr.html.thead}
  const thead(
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
      tag: 'thead',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.tbody}
/// The &lt;tbody&gt; HTML element encapsulates a set of table rows (&lt;tr&gt; elements), indicating that they comprise the body of a table's (main) data.
/// {@endtemplate}
final class tbody extends StatelessComponent {
  /// {@macro jaspr.html.tbody}
  const tbody(
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
      tag: 'tbody',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.tfoot}
/// The &lt;tfoot&gt; HTML element encapsulates a set of table rows (&lt;tr&gt; elements), indicating that they comprise the foot of a table with information about the table's columns. This is usually a summary of the columns, e.g., a sum of the given numbers in a column.
/// {@endtemplate}
final class tfoot extends StatelessComponent {
  /// {@macro jaspr.html.tfoot}
  const tfoot(
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
      tag: 'tfoot',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.th}
/// The &lt;th&gt; HTML element defines a cell as the header of a group of table cells and may be used as a child of the &lt;tr&gt; element. The exact nature of this group is defined by the scope and headers attributes.
/// {@endtemplate}
final class th extends StatelessComponent {
  /// {@macro jaspr.html.th}
  const th(
    this.children, {
    this.abbr,
    this.colspan,
    this.headers,
    this.rowspan,
    this.scope,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// A short, abbreviated description of the header cell's content provided as an alternative label to use for the header cell when referencing the cell in other contexts. Some user-agents, such as speech readers, may present this description before the content itself.
  final String? abbr;

  /// A non-negative integer value indicating how many columns the header cell spans or extends. The default value is 1. User agents dismiss values higher than 1000 as incorrect, defaulting such values to 1.
  final int? colspan;

  /// A list of space-separated strings corresponding to the id attributes of the &lt;th&gt; elements that provide the headers for this header cell.
  final String? headers;

  /// A non-negative integer value indicating how many rows the header cell spans or extends. The default value is 1; if its value is set to 0, the header cell will extends to the end of the table grouping section (&lt;thead&gt;, &lt;tbody&gt;, &lt;tfoot&gt;, even if implicitly defined), that the &lt;th&gt; belongs to. Values higher than 65534 are clipped at 65534.
  final int? rowspan;

  /// Defines the cells that the header (defined in the &lt;th&gt;) element relates to. Possible enumerated values are:
  /// - row: the header relates to all cells of the row it belongs to;
  /// - col: the header relates to all cells of the column it belongs to;
  /// - rowgroup: the header belongs to a rowgroup and relates to all of its cells;
  /// - colgroup: the header belongs to a colgroup and relates to all of its cells.
  /// If the scope attribute is not specified, or its value is not row, col, rowgroup, or colgroup, then browsers automatically select the set of cells to which the header cell applies.
  final String? scope;

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
      tag: 'th',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'abbr': ?abbr,
        'colspan': ?colspan?.toString(),
        'headers': ?headers,
        'rowspan': ?rowspan?.toString(),
        'scope': ?scope,
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.tr}
/// The &lt;tr&gt; HTML element defines a row of cells in a table. The row's cells can then be established using a mix of &lt;td&gt; (data cell) and &lt;th&gt; (header cell) elements.
/// {@endtemplate}
final class tr extends StatelessComponent {
  /// {@macro jaspr.html.tr}
  const tr(
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
      tag: 'tr',
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.td}
/// The &lt;td&gt; HTML element defines a cell of a table that contains data and may be used as a child of the &lt;tr&gt; element.
/// {@endtemplate}
final class td extends StatelessComponent {
  /// {@macro jaspr.html.td}
  const td(
    this.children, {
    this.colspan,
    this.headers,
    this.rowspan,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Contains a non-negative integer value that indicates how many columns the data cell spans or extends. The default value is 1. User agents dismiss values higher than 1000 as incorrect, setting to the default value (1).
  final int? colspan;

  /// Contains a list of space-separated strings, each corresponding to the id attribute of the &lt;th&gt; elements that provide headings for this table cell.
  final String? headers;

  /// Contains a non-negative integer value that indicates for how many rows the data cell spans or extends. The default value is 1; if its value is set to 0, it extends until the end of the table grouping section (&lt;thead&gt;, &lt;tbody&gt;, &lt;tfoot&gt;, even if implicitly defined), that the cell belongs to. Values higher than 65534 are clipped to 65534.
  final int? rowspan;

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
      tag: 'td',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {
        ...?attributes,
        'colspan': ?colspan?.toString(),
        'headers': ?headers,
        'rowspan': ?rowspan?.toString(),
      },
      events: events,
      children: children,
    );
  }
}

/// {@template jaspr.html.col}
/// The &lt;col&gt; HTML element defines one or more columns in a column group represented by its parent &lt;colgroup&gt; element. The &lt;col&gt; element is only valid as a child of a &lt;colgroup&gt; element that has no span attribute defined.
/// {@endtemplate}
final class col extends StatelessComponent {
  /// {@macro jaspr.html.col}
  const col({
    this.span,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Specifies the number of consecutive columns the &lt;col&gt; element spans. The value must be a positive integer greater than zero. If not present, its default value is 1.
  final int? span;

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
      tag: 'col',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, 'span': ?span?.toString()},
      events: events,
    );
  }
}

/// {@template jaspr.html.colgroup}
/// The &lt;colgroup&gt; HTML element defines a group of columns within a table.
/// {@endtemplate}
final class colgroup extends StatelessComponent {
  /// {@macro jaspr.html.colgroup}
  const colgroup(
    this.children, {
    this.span,
    this.id,
    this.classes,
    this.styles,
    this.attributes,
    this.events,
    super.key,
  });

  /// Specifies the number of consecutive columns the &lt;colgroup&gt; element spans. The value must be a positive integer greater than zero. If not present, its default value is 1.
  final int? span;

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
      tag: 'colgroup',
      id: id,
      classes: classes,
      styles: styles,
      attributes: {...?attributes, 'span': ?span?.toString()},
      events: events,
      children: children,
    );
  }
}
