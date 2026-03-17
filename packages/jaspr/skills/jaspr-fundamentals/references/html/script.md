# script

Signature of the script component:

```dart
const script({
  /// This attribute specifies the URI of an external script; this can be used as an alternative to embedding a script directly within a document.
  String? src,
  /// For classic scripts, if the async attribute is present, then the classic script will be fetched in parallel to parsing and evaluated as soon as it is available.
  /// 
  /// For module scripts, if the async attribute is present then the scripts and all their dependencies will be executed in the defer queue, therefore they will get fetched in parallel to parsing and evaluated as soon as they are available.
  /// 
  /// This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse. defer has a similar effect in this case.
  bool async = false,
  /// This Boolean attribute is set to indicate to a browser that the script is meant to be executed after the document has been parsed, but before firing DOMContentLoaded.
  /// 
  /// Scripts with the defer attribute will prevent the DOMContentLoaded event from firing until the script has loaded and finished evaluating.
  /// 
  /// Scripts with the defer attribute will execute in the order in which they appear in the document.
  /// 
  /// This attribute allows the elimination of parser-blocking JavaScript where the browser would have to load and evaluate scripts before continuing to parse. async has a similar effect in this case.
  bool defer = false,
  /// The content of the script element, if it is not an external script.
  String? content,
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
script(src: '...')
```