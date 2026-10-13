import 'dart:async';

import '../../framework/framework.dart';
import '../markup_render_object.dart';
import '../server_binding.dart';

abstract base class ElementBoundaryAdapter extends RenderAdapter {
  /// Priority for client component boundaries.
  ///
  /// This is set to an arbitrary high value so that the client component markers
  /// always wrap other element boundaries applied to the same element.
  static const clientComponentBoundaryPriority = 1000;

  /// Priority for server component boundaries.
  ///
  /// This is set to an arbitrary value higher than [clientComponentBoundaryPriority]
  /// so that the server component markers always wrap other element boundaries including
  /// client component markers applied to the same element.
  static const serverComponentBoundaryPriority = 2000;

  ElementBoundaryAdapter(this.element, {this.priority = 0});

  final Element element;

  /// Priority of this boundary.
  ///
  /// When multiple adapters are applied to the same element, higher priority adapters are
  /// wrapping lower priority ones, independent of the order they are applied in.
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
