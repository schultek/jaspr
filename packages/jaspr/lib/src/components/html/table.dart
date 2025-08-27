part of 'html.dart';

/// The &lt;table&gt; HTML element represents tabular data—that is, information presented in a two-dimensional table comprised of rows and columns of cells containing data.
Component table(List<Component> children,
    {Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'table',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;caption&gt; HTML element specifies the caption (or title) of a table, providing the table an accessible description.
Component caption(List<Component> children,
    {Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'caption',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;thead&gt; HTML element encapsulates a set of table rows (&lt;tr&gt; elements), indicating that they comprise the head of a table with information about the table's columns. This is usually in the form of column headers (&lt;th&gt; elements).
Component thead(List<Component> children,
    {Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'thead',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;tbody&gt; HTML element encapsulates a set of table rows (&lt;tr&gt; elements), indicating that they comprise the body of a table's (main) data.
Component tbody(List<Component> children,
    {Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'tbody',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;tfoot&gt; HTML element encapsulates a set of table rows (&lt;tr&gt; elements), indicating that they comprise the foot of a table with information about the table's columns. This is usually a summary of the columns, e.g., a sum of the given numbers in a column.
Component tfoot(List<Component> children,
    {Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'tfoot',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;th&gt; HTML element defines a cell as the header of a group of table cells and may be used as a child of the &lt;tr&gt; element. The exact nature of this group is defined by the scope and headers attributes.
///
/// - [abbr]: A short, abbreviated description of the header cell's content provided as an alternative label to use for the header cell when referencing the cell in other contexts. Some user-agents, such as speech readers, may present this description before the content itself.
/// - [colspan]: A non-negative integer value indicating how many columns the header cell spans or extends. The default value is 1. User agents dismiss values higher than 1000 as incorrect, defaulting such values to 1.
/// - [headers]: A list of space-separated strings corresponding to the id attributes of the &lt;th&gt; elements that provide the headers for this header cell.
/// - [rowspan]: A non-negative integer value indicating how many rows the header cell spans or extends. The default value is 1; if its value is set to 0, the header cell will extends to the end of the table grouping section (&lt;thead&gt;, &lt;tbody&gt;, &lt;tfoot&gt;, even if implicitly defined), that the &lt;th&gt; belongs to. Values higher than 65534 are clipped at 65534.
/// - [scope]: Defines the cells that the header (defined in the &lt;th&gt;) element relates to. Possible enumerated values are:
///   - row: the header relates to all cells of the row it belongs to;
///   - col: the header relates to all cells of the column it belongs to;
///   - rowgroup: the header belongs to a rowgroup and relates to all of its cells;
///   - colgroup: the header belongs to a colgroup and relates to all of its cells.
///   If the scope attribute is not specified, or its value is not row, col, rowgroup, or colgroup, then browsers automatically select the set of cells to which the header cell applies.
Component th(List<Component> children,
    {String? abbr,
    int? colspan,
    String? headers,
    int? rowspan,
    String? scope,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'th',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...?attributes,
      if (abbr != null) 'abbr': abbr,
      if (colspan != null) 'colspan': '$colspan',
      if (headers != null) 'headers': headers,
      if (rowspan != null) 'rowspan': '$rowspan',
      if (scope != null) 'scope': scope,
    },
    events: events,
    children: children,
  );
}

/// The &lt;tr&gt; HTML element defines a row of cells in a table. The row's cells can then be established using a mix of &lt;td&gt; (data cell) and &lt;th&gt; (header cell) elements.
Component tr(List<Component> children,
    {Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'tr',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: attributes,
    events: events,
    children: children,
  );
}

/// The &lt;td&gt; HTML element defines a cell of a table that contains data and may be used as a child of the &lt;tr&gt; element.
///
/// - [colspan]: Contains a non-negative integer value that indicates how many columns the data cell spans or extends. The default value is 1. User agents dismiss values higher than 1000 as incorrect, setting to the default value (1).
/// - [headers]: Contains a list of space-separated strings, each corresponding to the id attribute of the &lt;th&gt; elements that provide headings for this table cell.
/// - [rowspan]: Contains a non-negative integer value that indicates for how many rows the data cell spans or extends. The default value is 1; if its value is set to 0, it extends until the end of the table grouping section (&lt;thead&gt;, &lt;tbody&gt;, &lt;tfoot&gt;, even if implicitly defined), that the cell belongs to. Values higher than 65534 are clipped to 65534.
Component td(List<Component> children,
    {int? colspan,
    String? headers,
    int? rowspan,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'td',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...?attributes,
      if (colspan != null) 'colspan': '$colspan',
      if (headers != null) 'headers': headers,
      if (rowspan != null) 'rowspan': '$rowspan',
    },
    events: events,
    children: children,
  );
}

/// The &lt;col&gt; HTML element defines one or more columns in a column group represented by its parent &lt;colgroup&gt; element. The &lt;col&gt; element is only valid as a child of a &lt;colgroup&gt; element that has no span attribute defined.
///
/// - [span]: Specifies the number of consecutive columns the &lt;col&gt; element spans. The value must be a positive integer greater than zero. If not present, its default value is 1.
Component col(
    {int? span,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'col',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...?attributes,
      if (span != null) 'span': '$span',
    },
    events: events,
  );
}

/// The &lt;colgroup&gt; HTML element defines a group of columns within a table.
///
/// - [span]: Specifies the number of consecutive columns the &lt;colgroup&gt; element spans. The value must be a positive integer greater than zero. If not present, its default value is 1.
Component colgroup(List<Component> children,
    {int? span,
    Key? key,
    String? id,
    String? classes,
    Styles? styles,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events}) {
  return DomComponent(
    tag: 'colgroup',
    key: key,
    id: id,
    classes: classes,
    styles: styles,
    attributes: {
      ...?attributes,
      if (span != null) 'span': '$span',
    },
    events: events,
    children: children,
  );
}
