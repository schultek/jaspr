import 'package:jaspr/jaspr.dart';

import 'mobx_hooks.dart' show HookCtx, globalHookContext;

/// Tracks dependencies using MobX and allows for Hooks usage
/// in every [Component] children of this one.
///
/// There should only be one instance of this within a given subtree.
/// A [MobXHooksObserverComponent] should not have a component
/// of the same type as children.
class MobXHooksObserverComponent extends ObserverComponent {
  /// Tracks dependencies using MobX and allows for Hooks usage
  /// in every [Component] children of this one.
  ///
  /// There should only be one instance of this within a given subtree.
  /// A [MobXHooksObserverComponent] should not have a component
  /// of the same type as children.
  const MobXHooksObserverComponent({required super.child, super.key});

  @override
  MobXHooksObserverElement createElement() => MobXHooksObserverElement(this);
}

class MobXHooksObserverElement extends ObserverElement {
  MobXHooksObserverElement(super.component);

  final Map<Element, HookCtx> hookContexts = {};

  @override
  void unmount() {
    for (final hook in hookContexts.values) {
      hook.dispose();
    }
    hookContexts.clear();
    super.unmount();
  }

  @override
  void willRebuildElement(Element element) {
    final ctx = hookContexts.putIfAbsent(
      element,
      () => HookCtx(element.markNeedsBuild),
    );
    ctx.startTracking();

    print('willRebuildElement ${ctx.hashCode} ${element.hashCode}');
  }

  @override
  void didRebuildElement(Element element) {
    assert(globalHookContext == hookContexts[element]);
    print(
        'didRebuildElement ${globalHookContext.hashCode} ${element.hashCode}');

    globalHookContext.endTracking();
  }

  @override
  void didUnmountElement(Element element) {
    final ctx = hookContexts.remove(element);
    print('didUnmountElement ${ctx?.hashCode} ${element.hashCode}');
    if (ctx != null) {
      ctx.dispose();
    }
  }
}
