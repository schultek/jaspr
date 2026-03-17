# th

Signature of the th component:

```dart
const th(List<Component> children, {
  /// A short, abbreviated description of the header cell's content provided as an alternative label to use for the header cell when referencing the cell in other contexts. Some user-agents, such as speech readers, may present this description before the content itself.
  String? abbr,
  /// A non-negative integer value indicating how many columns the header cell spans or extends. The default value is 1. User agents dismiss values higher than 1000 as incorrect, defaulting such values to 1.
  int? colspan,
  /// A list of space-separated strings corresponding to the id attributes of the <th> elements that provide the headers for this header cell.
  String? headers,
  /// A non-negative integer value indicating how many rows the header cell spans or extends. The default value is 1; if its value is set to 0, the header cell will extends to the end of the table grouping section (<thead>, <tbody>, <tfoot>, even if implicitly defined), that the <th> belongs to. Values higher than 65534 are clipped at 65534.
  int? rowspan,
  /// Defines the cells that the header (defined in the <th>) element relates to. Possible enumerated values are:
  /// - row: the header relates to all cells of the row it belongs to;
  /// - col: the header relates to all cells of the column it belongs to;
  /// - rowgroup: the header belongs to a rowgroup and relates to all of its cells;
  /// - colgroup: the header belongs to a colgroup and relates to all of its cells.
  /// If the scope attribute is not specified, or its value is not row, col, rowgroup, or colgroup, then browsers automatically select the set of cells to which the header cell applies.
  String? scope,
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
th(abbr: '...', [
  // ...
])
```