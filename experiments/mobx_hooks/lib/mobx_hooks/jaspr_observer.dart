import 'package:jaspr/jaspr.dart';

import 'mobx_hooks.dart';

class MobXHooksObserverComponent extends ObserverComponent {
  /// Initializes [key] for subclasses.
  const MobXHooksObserverComponent({required super.child});

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
