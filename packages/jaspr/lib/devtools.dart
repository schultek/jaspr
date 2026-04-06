/// Public API for Jaspr DevTools integration.
///
/// This library exports the types needed by the standalone DevTools app
/// to communicate with and display the component tree.
library;

export 'src/devtools/devtools_protocol.dart';
export 'src/devtools/tree_snapshot.dart' show InspectorNode;
