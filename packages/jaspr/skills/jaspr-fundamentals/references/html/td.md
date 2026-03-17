# td

Signature of the td component:

```dart
const td(List<Component> children, {
  /// Contains a non-negative integer value that indicates how many columns the data cell spans or extends. The default value is 1. User agents dismiss values higher than 1000 as incorrect, setting to the default value (1).
  int? colspan,
  /// Contains a list of space-separated strings, each corresponding to the id attribute of the <th> elements that provide headings for this table cell.
  String? headers,
  /// Contains a non-negative integer value that indicates for how many rows the data cell spans or extends. The default value is 1; if its value is set to 0, it extends until the end of the table grouping section (<thead>, <tbody>, <tfoot>, even if implicitly defined), that the cell belongs to. Values higher than 65534 are clipped to 65534.
  int? rowspan,
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
td(colspan: 1, [
  // ...
])
```