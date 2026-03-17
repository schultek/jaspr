import '../framework/framework.dart';

/// Maximum recursion depth when walking the component tree.
///
/// Prevents stack overflow on pathological or deeply nested trees.
const _kMaxSnapshotDepth = 200;

/// A serialized snapshot of a single node in the component tree.
///
/// Each node captures the runtime type, display label, depth, and structural
/// metadata of the corresponding [Element]. The tree of [InspectorNode]s is
/// built by [snapshotTree] and consumed by the inspector panel for rendering.
class InspectorNode {
  /// Creates an [InspectorNode] with all required metadata fields.
  InspectorNode({
    required this.id,
    required this.componentType,
    required this.displayLabel,
    required this.depth,
    required this.isStateful,
    required this.domTag,
    required this.textContent,
    required this.hasRenderObject,
    required this.children,
    this.sourceLocation,
    this.domId,
    this.domClasses,
    this.domAttributes,
    this.stateType,
    this.eventCount = 0,
    this.builtBy,
    this.stateFields,
    this.wasHydrated,
  });

  /// Unique identifier for this node, derived from the element's [hashCode].
  final int id;

  /// The runtime type name of the component (e.g. `'MyWidget'`).
  final String componentType;

  /// A human-readable label shown in the tree (e.g. `'<div>'`, `'Text("hello")'`).
  final String displayLabel;

  /// The depth of this element in the framework's element tree.
  final int depth;

  /// Whether the element is a [StatefulElement].
  final bool isStateful;

  /// The HTML tag name if this is a [DomComponent], otherwise `null`.
  final String? domTag;

  /// The text content if this is a [Text] component, otherwise `null`.
  final String? textContent;

  /// Whether this element is a [RenderObjectElement].
  final bool hasRenderObject;

  /// Direct children of this node in the component tree.
  final List<InspectorNode> children;

  /// Source file and line where this component was created (debug only).
  final String? sourceLocation;

  /// The DOM element id, if this is a [DomComponent] with an id.
  final String? domId;

  /// The CSS classes, if this is a [DomComponent] with classes.
  final String? domClasses;

  /// DOM attributes, if this is a [DomComponent] with attributes.
  final Map<String, String>? domAttributes;

  /// The runtime type name of the [State] object, if this is a [StatefulElement].
  final String? stateType;

  /// Number of event handlers registered on this component.
  final int eventCount;

  /// The component type name of the element whose build() produced this node.
  final String? builtBy;

  /// State field names to their string values, from [State.debugDescribeState].
  final Map<String, String>? stateFields;

  /// Whether this node's DOM was hydrated from server-rendered HTML.
  ///
  /// `true` = SSR (hydrated), `false` = CSR (client-created), `null` = unknown.
  final bool? wasHydrated;
}

/// Walks the element tree starting from [root] and returns a tree of
/// [InspectorNode]s.
///
/// Populates [registry] with a mapping from node id (element hashCode) to the
/// corresponding [Element], allowing the inspector to look up DOM nodes for
/// highlight positioning.
///
/// When [classLocations] is provided, it maps component class names to their
/// source file locations (e.g. `'App' → 'package:my_app/app.dart:5'`).
/// This is used by the DDC-based source resolver for accurate source navigation.
///
/// Recursion stops at [_kMaxSnapshotDepth] to prevent stack overflow on
/// extremely deep trees.
InspectorNode snapshotTree(Element root, Map<int, Element> registry, {Map<String, String>? classLocations}) {
  return _snapshotElement(root, registry, 0, classLocations);
}

InspectorNode _snapshotElement(
  Element element,
  Map<int, Element> registry,
  int currentDepth,
  Map<String, String>? classLocations,
) {
  final id = element.hashCode;
  registry[id] = element;

  final component = element.component;
  final componentType = component.runtimeType.toString();
  final isStateful = element is StatefulElement;
  final isRenderObject = element is RenderObjectElement;

  String? domTag;
  String? textContent;
  String? domId;
  String? domClasses;
  Map<String, String>? domAttributes;
  String? stateType;
  Map<String, String>? stateFields;
  int eventCount = 0;

  if (component is DomComponent) {
    domTag = component.tag;
    domId = component.id;
    domClasses = component.classes;
    domAttributes = component.attributes;
    eventCount = component.events?.length ?? 0;
  }
  if (component is Text) {
    textContent = component.text;
  }
  if (element is StatefulElement) {
    stateType = element.state.runtimeType.toString();
    final described = element.state.debugDescribeState();
    if (described.isNotEmpty) stateFields = described;
  }

  // Resolve source location: prefer DDC class locations, fall back to stack trace.
  final sourceLocation = classLocations?[componentType] ??
      _parseSourceLocation(element.debugCreationStack);

  // Determine hydration status.
  // Only trust non-null values — null means "not applicable" (fragments, anchors).
  bool? wasHydrated;
  if (element is RenderObjectElement) {
    final h = element.renderObject.debugWasHydrated;
    wasHydrated = h ?? _inferHydrationStatus(element);
  } else {
    wasHydrated = _inferHydrationStatus(element);
  }

  final builtBy = element.debugBuildOwnerElement?.component.runtimeType.toString();

  final displayLabel = _buildLabel(componentType, isStateful, domTag, textContent);

  final children = <InspectorNode>[];
  if (currentDepth < _kMaxSnapshotDepth) {
    element.visitChildren((child) {
      children.add(_snapshotElement(child, registry, currentDepth + 1, classLocations));
    });
  }

  return InspectorNode(
    id: id,
    componentType: componentType,
    displayLabel: displayLabel,
    depth: element.depth,
    isStateful: isStateful,
    domTag: domTag,
    textContent: textContent,
    hasRenderObject: isRenderObject,
    children: children,
    sourceLocation: sourceLocation,
    domId: domId,
    domClasses: domClasses,
    domAttributes: domAttributes,
    stateType: stateType,
    eventCount: eventCount,
    builtBy: builtBy,
    stateFields: stateFields,
    wasHydrated: wasHydrated,
  );
}

/// Infers hydration status for non-render-object elements by walking to
/// the first [RenderObjectElement] descendant.
bool? _inferHydrationStatus(Element element) {
  bool? result;
  element.visitChildren((child) {
    if (result != null) return;
    if (child is RenderObjectElement) {
      final h = child.renderObject.debugWasHydrated;
      if (h != null) {
        result = h;
      } else {
        // Render object with null status (fragment/anchor) — look deeper.
        result = _inferHydrationStatus(child);
      }
    } else {
      result = _inferHydrationStatus(child);
    }
  });
  return result;
}

/// Parses a [StackTrace] to find the first user-code frame (skipping framework internals).
String? _parseSourceLocation(StackTrace? stack) {
  if (stack == null) return null;
  final lines = stack.toString().split('\n');
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    // Filter framework internals — match both package: and packages/ URI formats.
    if (trimmed.contains('jaspr/src/framework/')) continue;
    if (trimmed.contains('jaspr/src/foundation/')) continue;
    if (trimmed.contains('jaspr/src/devtools/')) continue;
    if (trimmed.contains('jaspr/src/client/')) continue;
    if (trimmed.contains('dart:')) continue;
    if (trimmed.contains('dart_sdk')) continue;
    // Extract "package:foo/bar.dart 42:15" or similar.
    final match = RegExp(r'(packages?[:/]\S+\.dart)\s+(\d+:\d+)').firstMatch(trimmed);
    if (match != null) return '${match.group(1)}:${match.group(2)}';
    // Fallback: return the whole trimmed line.
    return trimmed;
  }
  return null;
}

String _buildLabel(String type, bool isStateful, String? domTag, String? textContent) {
  if (domTag != null) return '<$domTag>';
  if (textContent != null) {
    final truncated = textContent.length > 30 ? '${textContent.substring(0, 30)}...' : textContent;
    return "Text('$truncated')";
  }
  if (isStateful) return '$type [Stateful]';
  return type;
}
