import 'dart:async';

import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';

/// A [RenderAdapter] that wraps the rendered output of [element] in a [ChildGroup],
/// such as to surround it with markers.
///
/// Boundaries around the same output nest by element depth,
/// so the boundary of an ancestor encloses those of its descendants.
abstract base class ElementBoundaryAdapter extends RenderAdapter {
  /// The [priority] of the boundary around a @client component.
  ///
  /// Higher than the default priority, so client component markers
  /// enclose the default-priority boundaries around the same element.
  static const int clientComponentBoundaryPriority = 1000;

  /// The [priority] of the boundary around a server component.
  ///
  /// Higher than [clientComponentBoundaryPriority], so server component markers
  /// enclose all other boundaries around the same element,
  /// including those of a @client component passed as a server component.
  static const int serverComponentBoundaryPriority = 2000;

  /// Creates an adapter for the boundary around [element]'s output.
  ElementBoundaryAdapter(this.element, {this.priority = 0});

  /// The element whose rendered output this boundary wraps.
  final Element element;

  /// The order of this boundary among the boundaries around the same element.
  ///
  /// Higher priority boundaries enclose lower priority ones,
  /// regardless of the order their adapters were added in.
  /// At equal priority, the boundary of the adapter added last is outermost.
  final int priority;

  /// The group wrapping [element]'s output, created in [prepare]
  /// and passed to [prepareBoundary] and [applyBoundary].
  late final ChildGroup _group;

  @override
  FutureOr<void> prepare() {
    final parent = element.parentRenderObjectElement!.renderObject as MarkupRenderObject;
    _group = parent.children.wrapElement(element, priority);
    prepareBoundary(_group);
  }

  @override
  void apply(MarkupRenderObject root) => applyBoundary(_group);

  /// Called with the group wrapping [element]'s output, before any adapter is applied.
  ///
  /// Entries inserted into [group] here don't affect how the groups of other adapters nest.
  /// Prefer [applyBoundary] for mutations that depend on other adapters.
  void prepareBoundary(ChildGroup group) {}

  /// Called with the same [group] as [prepareBoundary], once all adapters are prepared.
  void applyBoundary(ChildGroup group) {}
}
