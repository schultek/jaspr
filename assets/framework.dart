class ValueKey<T> extends LocalKey {
  const ValueKey(this.value);

  final T value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is ValueKey<T> && other.value == value;
  }

  @override
  int get hashCode => Object.hashAll([runtimeType, value]);

  @override
  String toString() {
    final String valueString = T == String ? "<'$value'>" : '<$value>';

    if (runtimeType == ValueKey<T>) {
      return '[$valueString]';
    }
    return '[$T $valueString]';
  }
}

class UniqueKey extends LocalKey {
  // ignore: prefer_const_constructors_in_immutables
  UniqueKey();

  @override
  String toString() => '[#$hashCode]';
}

@optionalTypeArgs
class GlobalKey<T extends State<StatefulComponent>> extends Key {
  const GlobalKey() : super.empty();

  Element? get _currentElement => ComponentsBinding._globalKeyRegistry[this];

  BuildContext? get currentContext => _currentElement;

  Component? get currentComponent => _currentElement?.component;

  T? get currentState {
    final Element? element = _currentElement;
    if (element is StatefulElement) {
      final StatefulElement statefulElement = element;
      final State state = statefulElement.state;
      if (state is T) return state;
    }
    return null;
  }
}

@optionalTypeArgs
class GlobalObjectKey<T extends State<StatefulComponent>> extends GlobalKey<T> {
  const GlobalObjectKey(this.value) : super();

  final Object value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is GlobalObjectKey<T> && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);
}

@immutable
abstract class Component {
  const Component({this.key});

  final Key? key;

  Element createElement();

  static bool canUpdate(Component oldComponent, Component newComponent) {
    return oldComponent.runtimeType == newComponent.runtimeType && oldComponent.key == newComponent.key;
  }
}

abstract class StatelessComponent extends Component {
  const StatelessComponent({super.key});

  @override
  Element createElement() => StatelessElement(this);

  @protected
  Iterable<Component> build(BuildContext context);

  bool shouldRebuild(covariant Component newComponent) {
    return true;
  }
}

abstract class StatefulComponent extends Component {
  const StatefulComponent({super.key});

  @override
  Element createElement() => StatefulElement(this);

  State createState();
}

enum _StateLifecycle {
  created,

  initialized,

  ready,

  defunct,
}

typedef StateSetter = void Function(VoidCallback fn);

@optionalTypeArgs
abstract class State<T extends StatefulComponent> {
  T get component => _component!;
  T? _component;

  _StateLifecycle _debugLifecycleState = _StateLifecycle.created;

  bool _debugTypesAreRight(Component component) => component is T;

  BuildContext get context => _element!;

  StatefulElement? _element;

  bool get mounted => _element != null;

  @protected
  @mustCallSuper
  void initState() {
    assert(_debugLifecycleState == _StateLifecycle.created);
  }

  bool shouldRebuild(covariant T newComponent) {
    return true;
  }

  @mustCallSuper
  @protected
  void didUpdateComponent(covariant T oldComponent) {}

  @protected
  void setState(VoidCallback fn) {
    assert(_debugLifecycleState != _StateLifecycle.defunct);
    Object? result = fn() as dynamic;
    assert(
      result is! Future,
      'setState() callback argument returned a Future.\n\n'
      'Instead of performing asynchronous work inside a call to setState(), first '
      'execute the work (without updating the component state), and then synchronously '
      'update the state inside a call to setState().',
    );
    _element!.markNeedsBuild();
  }

  @protected
  @mustCallSuper
  void deactivate() {}

  @protected
  @mustCallSuper
  void activate() {}

  @mustCallSuper
  @protected
  void dispose() {
    assert(_debugLifecycleState == _StateLifecycle.ready);
    assert(() {
      _debugLifecycleState = _StateLifecycle.defunct;
      return true;
    }());
  }

  @protected
  Iterable<Component> build(BuildContext context);

  @protected
  @mustCallSuper
  void didChangeDependencies() {}
}

abstract class ProxyComponent extends Component {
  const ProxyComponent({
    this.child,
    this.children,
    super.key,
  }) : assert(child == null || children == null);

  final Component? child;
  final List<Component>? children;

  @override
  ProxyElement createElement() => ProxyElement(this);
}

abstract class InheritedComponent extends ProxyComponent {
  const InheritedComponent({super.child, super.children, super.key});

  @override
  InheritedElement createElement() => InheritedElement(this);

  @protected
  bool updateShouldNotify(covariant InheritedComponent oldComponent);
}

enum _ElementLifecycle {
  initial,
  active,
  inactive,
  defunct,
}

class _InactiveElements {
  final Set<Element> _elements = HashSet<Element>();

  void _unmount(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.visitChildren((Element child) {
      assert(child._parent == element);
      _unmount(child);
    });
    element.unmount();
    assert(element._lifecycleState == _ElementLifecycle.defunct);
  }

  void _unmountAll() {
    final List<Element> elements = _elements.toList()..sort(Element._sort);
    _elements.clear();

    for (var e in elements.reversed) {
      _unmount(e);
    }
    assert(_elements.isEmpty);
  }

  static void _deactivateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.active);
    element.deactivate();
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.visitChildren(_deactivateRecursively);
  }

  void add(Element element) {
    assert(!_elements.contains(element));
    assert(element._parent == null);
    if (element._lifecycleState == _ElementLifecycle.active) {
      element.detachRenderObject();
      _deactivateRecursively(element);
    }
    _elements.add(element);
  }

  void remove(Element element) {
    assert(_elements.contains(element));
    assert(element._parent == null);
    _elements.remove(element);
    assert(element._lifecycleState != _ElementLifecycle.active);
  }
}

typedef ElementVisitor = void Function(Element element);

sealed class BuildContext {
  Component get component;

  AppBinding get binding;

  bool get debugDoingBuild;

  InheritedComponent dependOnInheritedElement(InheritedElement ancestor, {Object? aspect});

  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>({Object? aspect});

  InheritedElement? getElementForInheritedComponentOfExactType<T extends InheritedComponent>();

  T? findAncestorStateOfType<T extends State>();

  void visitAncestorElements(bool Function(Element element) visitor);

  void visitChildElements(ElementVisitor visitor);

  void dispatchNotification(Notification notification);
}

class BuildOwner {
  final List<Element> _dirtyElements = <Element>[];

  bool _scheduledBuild = false;

  // ignore: prefer_final_fields
  bool _isFirstBuild = false;
  bool get isFirstBuild => _isFirstBuild;

  Future<void> performInitialBuild(Element element) async {
    element.mount(null, null);
    element.didMount();
  }

  final _InactiveElements _inactiveElements = _InactiveElements();

  bool? _dirtyElementsNeedsResorting;

  void scheduleBuildFor(Element element) {
    assert(!isFirstBuild);
    assert(element.dirty, 'scheduleBuildFor() called for a component that is not marked as dirty.');

    if (element._inDirtyList) {
      _dirtyElementsNeedsResorting = true;
      return;
    }
    if (!_scheduledBuild) {
      element.binding.scheduleBuild(performBuild);
      _scheduledBuild = true;
    }

    _dirtyElements.add(element);
    element._inDirtyList = true;
  }

  bool get debugBuilding => _debugBuilding;
  bool _debugBuilding = false;
  Element? _debugCurrentBuildTarget;

  int _debugStateLockLevel = 0;
  bool get _debugStateLocked => _debugStateLockLevel > 0;

  Future<void> lockState(dynamic Function() callback) async {
    assert(_debugStateLockLevel >= 0);
    assert(() {
      _debugStateLockLevel += 1;
      return true;
    }());
    try {
      var res = callback() as dynamic;
      if (res is Future) {
        await res;
      }
    } finally {
      assert(() {
        _debugStateLockLevel -= 1;
        return true;
      }());
    }
    assert(_debugStateLockLevel >= 0);
  }

  void performRebuildOn(Element child, void Function() whenComplete) {
    Object? result = child.performRebuild() as dynamic;
    assert(
      result is! Future,
      '${child.runtimeType}.performBuild() returned a Future while rebuilding.\n\n'
      'Only server builds are allowed to be asynchronous.',
    );
    whenComplete();
    child.attachRenderObject();
  }

  void performBuild() {
    assert(!isFirstBuild);

    assert(_debugStateLockLevel >= 0);
    assert(!_debugBuilding);

    assert(() {
      _debugStateLockLevel += 1;
      _debugBuilding = true;
      return true;
    }());

    try {
      _dirtyElements.sort(Element._sort);
      _dirtyElementsNeedsResorting = false;

      int dirtyCount = _dirtyElements.length;
      int index = 0;

      while (index < dirtyCount) {
        final Element element = _dirtyElements[index];
        assert(element._inDirtyList);

        try {
          element.rebuild();
          if (element._lifecycleState == _ElementLifecycle.active) {
            assert(!element._dirty, 'Build was not finished synchronously on $element');
          }
        } catch (e) {
          // TODO: properly report error
          print("Error on rebuilding component: $e");
          rethrow;
        }

        index += 1;
        if (dirtyCount < _dirtyElements.length || _dirtyElementsNeedsResorting!) {
          _dirtyElements.sort(Element._sort);
          _dirtyElementsNeedsResorting = false;
          dirtyCount = _dirtyElements.length;
          while (index > 0 && _dirtyElements[index - 1].dirty) {
            index -= 1;
          }
        }
      }

      assert(() {
        if (_dirtyElements
            .any((Element element) => element._lifecycleState == _ElementLifecycle.active && element.dirty)) {
          throw 'performBuild missed some dirty elements.';
        }
        return true;
      }());
    } finally {
      for (final Element element in _dirtyElements) {
        assert(element._inDirtyList);
        element._inDirtyList = false;
      }

      _dirtyElements.clear();
      _dirtyElementsNeedsResorting = null;

      lockState(_inactiveElements._unmountAll);

      _scheduledBuild = false;

      assert(_debugBuilding);
      assert(() {
        _debugBuilding = false;
        _debugStateLockLevel -= 1;
        return true;
      }());
    }
    assert(_debugStateLockLevel >= 0);
  }
}

mixin NotifiableElementMixin on Element {
  bool onNotification(Notification notification);

  @override
  void attachNotificationTree() {
    _notificationTree = _NotificationNode(_parent?._notificationTree, this);
  }
}

class _NotificationNode {
  _NotificationNode(this.parent, this.current);

  NotifiableElementMixin? current;
  _NotificationNode? parent;

  void dispatchNotification(Notification notification) {
    if (current?.onNotification(notification) ?? true) {
      return;
    }
    parent?.dispatchNotification(notification);
  }
}

abstract class Element implements BuildContext {
  Element(Component component) : _component = component;

  Element? _parent;
  Element? get parent => _parent;

  _NotificationNode? _notificationTree;

  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => identical(this, other);

  // Custom implementation of hash code optimized for the ".of" pattern used
  // with `InheritedComponents`.
  //
  // `Element.dependOnInheritedComponentOfExactType` relies heavily on hash-based
  // `Set` look-ups, putting this getter on the performance critical path.
  //
  // The value is designed to fit within the SMI representation. This makes
  // the cached value use less memory (one field and no extra heap objects) and
  // cheap to compare (no indirection).
  @nonVirtual
  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => _cachedHash;
  final int _cachedHash = _nextHashCode = (_nextHashCode + 1) % 0xffffff;
  static int _nextHashCode = 1;

  int get depth => _depth!;
  int? _depth;

  static int _sort(Element a, Element b) {
    if (a.depth < b.depth) {
      return -1;
    } else if (b.depth < a.depth) {
      return 1;
    } else if (b.dirty && !a.dirty) {
      return -1;
    } else if (a.dirty && !b.dirty) {
      return 1;
    }
    return 0;
  }

  @override
  Component get component => _component!;
  Component? _component;

  @override
  AppBinding get binding => _binding!;
  AppBinding? _binding;

  BuildOwner get owner => _owner!;
  BuildOwner? _owner;

  // This is used to verify that Element objects move through life in an
  // orderly fashion.
  _ElementLifecycle _lifecycleState = _ElementLifecycle.initial;

  void visitChildren(ElementVisitor visitor);

  @override
  void visitChildElements(ElementVisitor visitor) {
    visitChildren(visitor);
  }

  @protected
  Element? updateChild(Element? child, Component? newComponent, Element? prevSibling) {
    if (newComponent == null) {
      if (child != null) {
        if (_lastChild == child) {
          updateLastChild(prevSibling);
        }
        deactivateChild(child);
      }
      return null;
    }
    final Element newChild;
    if (child != null) {
      if (child._component == newComponent) {
        if (child._parentChanged || child._prevSibling != prevSibling) {
          child.updatePrevSibling(prevSibling);
        }
        newChild = child;
      } else if (child._parentChanged || Component.canUpdate(child.component, newComponent)) {
        if (child._parentChanged || child._prevSibling != prevSibling) {
          child.updatePrevSibling(prevSibling);
        }
        var oldComponent = child.component;
        child.update(newComponent);
        assert(child.component == newComponent);
        child.didUpdate(oldComponent);
        newChild = child;
      } else {
        deactivateChild(child);
        assert(child._parent == null);
        newChild = inflateComponent(newComponent, prevSibling);
      }
    } else {
      newChild = inflateComponent(newComponent, prevSibling);
    }

    if (_lastChild == prevSibling) {
      updateLastChild(newChild);
    }

    return newChild;
  }

  @protected
  List<Element> updateChildren(List<Element> oldChildren, List<Component> newComponents, {Set<Element>? forgottenChildren}) {
    Element? replaceWithNullIfForgotten(Element? child) {
      return child != null && forgottenChildren != null && forgottenChildren.contains(child) ? null : child;
    }

    // This attempts to diff the new child list (newComponents) with
    // the old child list (oldChildren), and produce a new list of elements to
    // be the new list of child elements of this element. The called of this
    // method is expected to update this render object accordingly.

    // The cases it tries to optimize for are:
    //  - the old list is empty
    //  - the lists are identical
    //  - there is an insertion or removal of one or more components in
    //    only one place in the list
    // If a component with a key is in both lists, it will be synced.
    // Components without keys might be synced but there is no guarantee.

    // The general approach is to sync the entire new list backwards, as follows:
    // 1. Walk the lists from the top, syncing nodes, until you no longer have
    //    matching nodes.
    // 2. Walk the lists from the bottom, without syncing nodes, until you no
    //    longer have matching nodes. We'll sync these nodes at the end. We
    //    don't sync them now because we want to sync all the nodes in order
    //    from beginning to end.
    // At this point we narrowed the old and new lists to the point
    // where the nodes no longer match.
    // 3. Walk the narrowed part of the old list to get the list of
    //    keys and sync null with non-keyed items.
    // 4. Walk the narrowed part of the new list forwards:
    //     * Sync non-keyed items with null
    //     * Sync keyed items with the source if it exists, else with null.
    // 5. Walk the bottom of the list again, syncing the nodes.
    // 6. Sync null with any items in the list of keys that are still
    //    mounted.

    if (oldChildren.length <= 1 && newComponents.length <= 1) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren.firstOrNull);
      var newChild = updateChild(oldChild, newComponents.firstOrNull, null);
      return [if (newChild != null) newChild];
    }

    int newChildrenTop = 0;
    int oldChildrenTop = 0;
    int newChildrenBottom = newComponents.length - 1;
    int oldChildrenBottom = oldChildren.length - 1;

    final List<Element?> newChildren = oldChildren.length == newComponents.length
        ? oldChildren
        : List<Element?>.filled(newComponents.length, null, growable: true);

    Element? prevChild;

    // Update the top of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      final Component newComponent = newComponents[newChildrenTop];
      if (oldChild == null || !Component.canUpdate(oldChild.component, newComponent)) break;
      final Element newChild = updateChild(oldChild, newComponent, prevChild)!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    // Scan the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenBottom]);
      final Component newComponent = newComponents[newChildrenBottom];
      if (oldChild == null || !Component.canUpdate(oldChild.component, newComponent)) break;
      oldChildrenBottom -= 1;
      newChildrenBottom -= 1;
    }

    Map<Key, Element>? retakeOldKeyedChildren;
    if (newChildrenTop <= newChildrenBottom && oldChildrenTop <= oldChildrenBottom) {
      final Map<Key, Component> newKeyedChildren = {};
      var newChildrenTopPeek = newChildrenTop;
      while (newChildrenTopPeek <= newChildrenBottom) {
        final Component newComponent = newComponents[newChildrenTopPeek];
        final Key? key = newComponent.key;
        if (key != null) {
          newKeyedChildren[key] = newComponent;
        }
        newChildrenTopPeek += 1;
      }

      if (newKeyedChildren.isNotEmpty) {
        retakeOldKeyedChildren = {};
        var oldChildrenTopPeek = oldChildrenTop;
        while (oldChildrenTopPeek <= oldChildrenBottom) {
          final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTopPeek]);
          if (oldChild != null) {
            final Key? key = oldChild.component.key;
            if (key != null) {
              final Component? newComponent = newKeyedChildren[key];
              if (newComponent != null && Component.canUpdate(oldChild.component, newComponent)) {
                retakeOldKeyedChildren[key] = oldChild;
              }
            }
          }
          oldChildrenTopPeek += 1;
        }
      }
    }

    while (newChildrenTop <= newChildrenBottom) {
      if (oldChildrenTop <= oldChildrenBottom) {
        final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
        if (oldChild != null) {
          final Key? key = oldChild.component.key;
          if (key == null || retakeOldKeyedChildren == null || !retakeOldKeyedChildren.containsKey(key)) {
            deactivateChild(oldChild);
          }
        }
        oldChildrenTop += 1;
      }

      Element? oldChild;
      final Component newComponent = newComponents[newChildrenTop];
      final Key? key = newComponent.key;
      if (key != null) {
        oldChild = retakeOldKeyedChildren?[key];
      }

      final Element newChild = updateChild(oldChild, newComponent, prevChild)!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
    }

    while (oldChildrenTop <= oldChildrenBottom) {
      final Element? oldChild = replaceWithNullIfForgotten(oldChildren[oldChildrenTop]);
      if (oldChild != null) {
        final Key? key = oldChild.component.key;
        if (key == null || retakeOldKeyedChildren == null || !retakeOldKeyedChildren.containsKey(key)) {
          deactivateChild(oldChild);
        }
      }
      oldChildrenTop += 1;
    }

    // We've scanned the whole list.
    newChildrenBottom = newComponents.length - 1;
    oldChildrenBottom = oldChildren.length - 1;

    // Update the bottom of the list.
    while ((oldChildrenTop <= oldChildrenBottom) && (newChildrenTop <= newChildrenBottom)) {
      final Element oldChild = oldChildren[oldChildrenTop];
      final Component newComponent = newComponents[newChildrenTop];
      final Element newChild = updateChild(oldChild, newComponent, prevChild)!;
      newChildren[newChildrenTop] = newChild;
      prevChild = newChild;
      newChildrenTop += 1;
      oldChildrenTop += 1;
    }

    assert(newChildren.every((element) => element != null));

    return newChildren.cast<Element>();
  }

  @mustCallSuper
  void mount(Element? parent, Element? prevSibling) {
    assert(_lifecycleState == _ElementLifecycle.initial);
    assert(_component != null);
    assert(_parent == null);
    assert(parent == null || parent._lifecycleState == _ElementLifecycle.active);

    _parent = parent;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent?._parentRenderObjectElement;

    _prevSibling = prevSibling;
    _prevAncestorSibling = _prevSibling ?? (_parent is RenderObjectElement ? null : _parent?._prevAncestorSibling);

    _lifecycleState = _ElementLifecycle.active;
    _depth = parent != null ? parent.depth + 1 : 1;

    if (parent != null) {
      _owner = parent.owner;
      _binding = parent.binding;
    }
    assert(_owner != null);
    assert(_binding != null);

    final Key? key = component.key;
    if (key is GlobalKey && binding.isClient) {
      ComponentsBinding._registerGlobalKey(key, this);
    }
    _updateInheritance();
    _updateObservers();
    attachNotificationTree();
  }

  @protected
  @mustCallSuper
  void didMount() {}

  @mustCallSuper
  void update(covariant Component newComponent) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_component != null);
    assert(newComponent != component);
    assert(_depth != null);
    assert(Component.canUpdate(component, newComponent));
    if (shouldRebuild(newComponent)) {
      _dirty = true;
    }
    _component = newComponent;
  }

  void didUpdate(covariant Component oldComponent) {
    if (_dirty) {
      rebuild();
    }
  }

  bool shouldRebuild(covariant Component newComponent);

  void _updateDepth(int parentDepth) {
    final int expectedDepth = parentDepth + 1;
    if (depth < expectedDepth) {
      _depth = expectedDepth;
      visitChildren((Element child) {
        child._updateDepth(expectedDepth);
      });
    }
  }

  Element? _retakeInactiveElement(GlobalKey key, Component newComponent) {
    final Element? element = key._currentElement;
    if (element == null) {
      return null;
    }
    if (!Component.canUpdate(element.component, newComponent)) {
      return null;
    }
    final Element? parent = element._parent;
    if (parent != null) {
      parent.forgetChild(element);
      parent.deactivateChild(element);
    }
    assert(element._parent == null);
    owner._inactiveElements.remove(element);
    return element;
  }

  @protected
  Element inflateComponent(Component newComponent, Element? prevSibling) {
    final Key? key = newComponent.key;
    if (key is GlobalKey) {
      final Element? newChild = _retakeInactiveElement(key, newComponent);
      if (newChild != null) {
        assert(newChild._parent == null);
        newChild._activateWithParent(this);
        newChild._parentChanged = true;
        final Element? updatedChild = updateChild(newChild, newComponent, prevSibling);
        assert(newChild == updatedChild);
        return updatedChild!;
      }
    }
    final Element newChild = newComponent.createElement();
    newChild.mount(this, prevSibling);
    newChild.didMount();
    assert(newChild._lifecycleState == _ElementLifecycle.active);
    return newChild;
  }

  @protected
  void deactivateChild(Element child) {
    assert(child._parent == this);
    child._parent = null;
    child._prevSibling = null;
    child._prevAncestorSibling = null;
    owner._inactiveElements.add(child);
  }

  @protected
  @mustCallSuper
  void forgetChild(Element child) {}

  void _activateWithParent(Element parent) {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    _parent = parent;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent._parentRenderObjectElement;
    _updateDepth(_parent!.depth);
    _activateRecursively(this);
    assert(_lifecycleState == _ElementLifecycle.active);
  }

  static void _activateRecursively(Element element) {
    assert(element._lifecycleState == _ElementLifecycle.inactive);
    element.activate();
    assert(element._lifecycleState == _ElementLifecycle.active);
    element.visitChildren(_activateRecursively);
  }

  @mustCallSuper
  void activate() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_component != null);
    assert(_owner != null);
    assert(_binding != null);
    assert(_parent != null);
    assert(_depth != null);
    final bool hadDependencies = (_dependencies != null && _dependencies!.isNotEmpty) || _hadUnsatisfiedDependencies;
    _lifecycleState = _ElementLifecycle.active;

    var parent = _parent!;
    _parentRenderObjectElement = parent is RenderObjectElement ? parent : parent._parentRenderObjectElement;

    _dependencies?.clear();
    _hadUnsatisfiedDependencies = false;
    _updateInheritance();
    _updateObservers();
    attachNotificationTree();
    if (_dirty) {
      owner.scheduleBuildFor(this);
    }
    if (hadDependencies) didChangeDependencies();
  }

  @mustCallSuper
  void deactivate() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_component != null);
    assert(_depth != null);
    if (_dependencies != null && _dependencies!.isNotEmpty) {
      for (var dependency in _dependencies!) {
        dependency.deactivateDependent(this);
      }
    }
    _inheritedElements = null;
    _lifecycleState = _ElementLifecycle.inactive;
  }

  @mustCallSuper
  void unmount() {
    assert(_lifecycleState == _ElementLifecycle.inactive);
    assert(_component != null);
    assert(_depth != null);
    assert(_owner != null);

    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (var observer in _observerElements!) {
        observer.didUnmountElement(this);
      }
      _observerElements = null;
    }

    final Key? key = component.key;
    if (key is GlobalKey) {
      ComponentsBinding._unregisterGlobalKey(key, this);
    }

    _parentRenderObjectElement = null;
    _component = null;
    _dependencies = null;
    _lifecycleState = _ElementLifecycle.defunct;
  }

  List<ObserverElement>? _observerElements;

  Map<Type, InheritedElement>? _inheritedElements;
  Set<InheritedElement>? _dependencies;
  bool _hadUnsatisfiedDependencies = false;

  @override
  InheritedComponent dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    _dependencies ??= HashSet<InheritedElement>();
    _dependencies!.add(ancestor);
    ancestor.updateDependencies(this, aspect);
    return ancestor.component;
  }

  @override
  T? dependOnInheritedComponentOfExactType<T extends InheritedComponent>({Object? aspect}) {
    final InheritedElement? ancestor = _inheritedElements == null ? null : _inheritedElements![T];
    if (ancestor != null) {
      return dependOnInheritedElement(ancestor, aspect: aspect) as T;
    }
    _hadUnsatisfiedDependencies = true;
    return null;
  }

  @override
  InheritedElement? getElementForInheritedComponentOfExactType<T extends InheritedComponent>() {
    final InheritedElement? ancestor = _inheritedElements == null ? null : _inheritedElements![T];
    return ancestor;
  }

  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _inheritedElements = _parent?._inheritedElements;
  }

  void _updateObservers() {
    assert(_lifecycleState == _ElementLifecycle.active);
    _observerElements = _parent?._observerElements;
  }

  @protected
  void attachNotificationTree() {
    _notificationTree = _parent?._notificationTree;
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulComponent>>() {
    Element? ancestor = _parent;
    while (ancestor != null) {
      if (ancestor is StatefulElement && ancestor.state is T) {
        break;
      }
      ancestor = ancestor._parent;
    }
    final StatefulElement? statefulAncestor = ancestor as StatefulElement?;
    return statefulAncestor?.state as T?;
  }

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
    Element? ancestor = _parent;
    while (ancestor != null && visitor(ancestor)) {
      ancestor = ancestor._parent;
    }
  }

  void didChangeDependencies() {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_debugCheckOwnerBuildTargetExists('didChangeDependencies'));
    markNeedsBuild();
  }

  bool _debugCheckOwnerBuildTargetExists(String methodName) {
    assert(() {
      if (owner._debugCurrentBuildTarget == null) {
        throw '$methodName for ${component.runtimeType} was called at an '
            'inappropriate time.';
      }
      return true;
    }());
    return true;
  }

  bool _dirty = true;
  bool get dirty => _dirty;

  // Whether this is in owner._dirtyElements. This is used to know whether we
  // should be adding the element back into the list when it's reactivated.
  // ignore: prefer_final_fields
  bool _inDirtyList = false;

  // We let component authors call setState from initState, didUpdateComponent, and
  // build even when state is locked because its convenient and a no-op anyway.
  // This flag ensures that this convenience is only allowed on the element
  // currently undergoing initState, didUpdateComponent, or build.
  bool _debugAllowIgnoredCallsToMarkNeedsBuild = false;
  bool _debugSetAllowIgnoredCallsToMarkNeedsBuild(bool value) {
    assert(_debugAllowIgnoredCallsToMarkNeedsBuild == !value);
    _debugAllowIgnoredCallsToMarkNeedsBuild = value;
    return true;
  }

  @mustCallSuper
  void markNeedsBuild() {
    assert(_lifecycleState != _ElementLifecycle.defunct);
    if (_lifecycleState != _ElementLifecycle.active) return;
    assert(_parentRenderObjectElement != null);
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(() {
      if (owner._debugBuilding) {
        assert(owner._debugCurrentBuildTarget != null);
        if (_debugIsInScope(owner._debugCurrentBuildTarget!)) {
          return true;
        }
        if (!_debugAllowIgnoredCallsToMarkNeedsBuild) {
          throw 'setState() or markNeedsBuild() called during build.';
        }
        // can only get here if we're not in scope, but ignored calls are allowed, and our call would somehow be ignored (since we're already dirty)
        assert(dirty);
      } else if (owner._debugStateLocked) {
        assert(!_debugAllowIgnoredCallsToMarkNeedsBuild);
        throw 'setState() or markNeedsBuild() called when component tree was locked.';
      }
      return true;
    }());

    if (_dirty) return;
    _dirty = true;
    owner.scheduleBuildFor(this);
  }

  bool _debugIsInScope(Element target) {
    Element? current = this;
    while (current != null) {
      if (target == current) {
        return true;
      }
      current = current._parent;
    }
    return false;
  }

  void rebuild() {
    assert(_lifecycleState != _ElementLifecycle.initial);
    if (_lifecycleState != _ElementLifecycle.active || !_dirty) {
      return;
    }
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(owner._debugStateLocked);
    Element? debugPreviousBuildTarget;
    assert(() {
      if (!binding.isClient && owner.isFirstBuild) return true;
      debugPreviousBuildTarget = owner._debugCurrentBuildTarget;
      owner._debugCurrentBuildTarget = this;
      return true;
    }());
    if (_observerElements != null && _observerElements!.isNotEmpty) {
      for (var observer in _observerElements!) {
        observer.willRebuildElement(this);
      }
    }
    owner.performRebuildOn(this, () {
      assert(() {
        if (!binding.isClient && owner.isFirstBuild) return true;
        assert(owner._debugCurrentBuildTarget == this);
        owner._debugCurrentBuildTarget = debugPreviousBuildTarget;
        return true;
      }());
      assert(!_dirty);
      if (_dependencies != null && _dependencies!.isNotEmpty) {
        for (var dependency in _dependencies!) {
          dependency.didRebuildDependent(this);
        }
      }
      if (_observerElements != null && _observerElements!.isNotEmpty) {
        for (var observer in _observerElements!) {
          observer.didRebuildElement(this);
        }
      }
    });
  }

  void performRebuild();

  void attachRenderObject() {}

  void detachRenderObject() {
    visitChildren((Element child) {
      assert(child._parent == this);
      child.detachRenderObject();
    });
  }

  @override
  void dispatchNotification(Notification notification) {
    _notificationTree?.dispatchNotification(notification);
  }

  RenderObjectElement? _parentRenderObjectElement;
  RenderObjectElement? get parentRenderObjectElement => _parentRenderObjectElement;

  Element? _prevSibling;
  Element? get prevSibling => _prevSibling;

  Element? _prevAncestorSibling;
  Element? get prevAncestorSibling => _prevAncestorSibling;

  Element? _lastChild;

  RenderObjectElement? _lastRenderObjectElement;
  RenderObjectElement? get lastRenderObjectElement => _lastRenderObjectElement;

  void updateLastChild(Element? child) {
    _lastChild = child;
    _lastRenderObjectElement = _lastChild?._lastRenderObjectElement;
    if (_parent?._lastChild == this && _parent?._lastRenderObjectElement != _lastRenderObjectElement) {
      _parent!.updateLastChild(this);
    }
  }

  var _parentChanged = false;

  void updatePrevSibling(Element? prevSibling) {
    assert(_lifecycleState == _ElementLifecycle.active);
    assert(_component != null);
    assert(_parent != null);
    assert(_parent!._lifecycleState == _ElementLifecycle.active);
    assert(_depth != null);
    assert(_parentRenderObjectElement != null);

    _prevSibling = prevSibling;
    _updateAncestorSiblingRecursively(_parentChanged);
    _parentChanged = false;
  }

  @mustCallSuper
  void _didUpdateSlot() {}

  void _updateAncestorSiblingRecursively(bool didChangeAncestor) {
    var newAncestorSibling = _prevSibling ?? (_parent is RenderObjectElement ? null : _parent?._prevAncestorSibling);
    if (didChangeAncestor || newAncestorSibling != _prevAncestorSibling) {
      _prevAncestorSibling = newAncestorSibling;
      _didUpdateSlot();
      if (this is! RenderObjectElement) {
        visitChildren((e) => e._updateAncestorSiblingRecursively(true));
      }
    }
  }
}

abstract class BuildableElement extends Element {
  BuildableElement(super.component);

  @protected
  Iterable<Element> get children => _children!.where((Element child) => !_forgottenChildren.contains(child));

  List<Element>? _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  bool _debugDoingBuild = false;
  @override
  bool get debugDoingBuild => _debugDoingBuild;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    assert(_children == null);
  }

  @override
  void didMount() {
    rebuild();
    super.didMount();
  }

  @override
  bool shouldRebuild(Component newComponent) {
    return true;
  }

  @override
  void performRebuild() {
    assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(true));
    List<Component>? built;
    try {
      assert(() {
        _debugDoingBuild = true;
        return true;
      }());
      built = build().toList();
      assert(() {
        _debugDoingBuild = false;
        return true;
      }());
    } catch (e, st) {
      _debugDoingBuild = false;
      // TODO: implement actual error component
      built = [
        DomComponent(
          tag: 'div',
          child: Text("Error on building component: $e"),
        ),
      ];
      print('Error: $e $st');
    } finally {
      _dirty = false;
      assert(_debugSetAllowIgnoredCallsToMarkNeedsBuild(false));
    }

    _children = updateChildren(_children ?? [], built, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

  @protected
  Iterable<Component> build();

  @override
  void visitChildren(ElementVisitor visitor) {
    for (var child in _children ?? []) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children != null);
    assert(_children!.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }
}

class StatelessElement extends BuildableElement {
  StatelessElement(StatelessComponent super.component);

  @override
  StatelessComponent get component => super.component as StatelessComponent;

  Future? _asyncFirstBuild;

  @override
  void didMount() {
    // We check if the component uses on of the mixins that support async initialization,
    // which will delay the call to [build()] until resolved during the first build.

    if (owner.isFirstBuild && !binding.isClient && component is OnFirstBuild) {
      var result = (component as OnFirstBuild).onFirstBuild(this);
      if (result is Future) {
        _asyncFirstBuild = result;
      }
    }

    super.didMount();
  }

  @override
  bool shouldRebuild(covariant Component newComponent) {
    return component.shouldRebuild(newComponent);
  }

  @override
  Iterable<Component> build() => component.build(this);

  @override
  FutureOr<void> performRebuild() {
    if (owner.isFirstBuild && _asyncFirstBuild != null) {
      return _asyncFirstBuild!.then((_) {
        super.performRebuild();
      });
    }
    super.performRebuild();
  }
}

class StatefulElement extends BuildableElement {
  StatefulElement(StatefulComponent component)
      : _state = component.createState(),
        super(component) {
    assert(() {
      if (!state._debugTypesAreRight(component)) {
        throw 'StatefulComponent.createState must return a subtype of State<${component.runtimeType}>\n\n'
            'The createState function for ${component.runtimeType} returned a state '
            'of type ${state.runtimeType}, which is not a subtype of '
            'State<${component.runtimeType}>, violating the contract for createState.';
      }
      return true;
    }());
    assert(state._element == null);
    state._element = this;
    assert(
      state._component == null,
      'The createState function for $component returned an old or invalid state '
      'instance: ${state._component}, which is not null, violating the contract '
      'for createState.',
    );
    state._component = component;
    assert(state._debugLifecycleState == _StateLifecycle.created);
  }

  @override
  Iterable<Component> build() => state.build(this);

  State? _state;
  State get state => _state!;

  Future? _asyncInitState;

  @override
  void didMount() {
    assert(state._debugLifecycleState == _StateLifecycle.created);

    // We check if state uses on of the mixins that support async initialization,
    // which will delay the call to [_initState()] until resolved during the first build.

    if (owner.isFirstBuild && state is PreloadStateMixin && !binding.isClient) {
      _asyncInitState = (state as PreloadStateMixin).preloadState().then((_) => _initState());
    } else {
      _initState();
    }

    super.didMount();
  }

  void _initState() {
    assert(state._debugLifecycleState == _StateLifecycle.created);
    try {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(true);
      Object? result = state.initState() as dynamic;
      assert(
        result is! Future,
        '${state.runtimeType}.initState() returned a Future.\n\n'
        'Rather than awaiting on asynchronous work directly inside of initState, '
        'call a separate method to do this work without awaiting it.\n\n'
        'If you need to do some async work before the first render, use PreloadStateMixin on State.',
      );
    } finally {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(false);
    }
    assert(() {
      state._debugLifecycleState = _StateLifecycle.initialized;
      return true;
    }());
    state.didChangeDependencies();
    assert(() {
      state._debugLifecycleState = _StateLifecycle.ready;
      return true;
    }());
  }

  @override
  FutureOr<void> performRebuild() {
    if (owner.isFirstBuild && _asyncInitState != null) {
      return _asyncInitState!.then((_) {
        if (_didChangeDependencies) {
          state.didChangeDependencies();
          _didChangeDependencies = false;
        }
        super.performRebuild();
      });
    }
    if (_didChangeDependencies) {
      state.didChangeDependencies();
      _didChangeDependencies = false;
    }
    super.performRebuild();
  }

  @override
  bool shouldRebuild(covariant StatefulComponent newComponent) {
    return state.shouldRebuild(newComponent);
  }

  @override
  void update(StatefulComponent newComponent) {
    super.update(newComponent);
    assert(component == newComponent);
    state._component = newComponent;
  }

  @override
  void didUpdate(StatefulComponent oldComponent) {
    try {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(true);
      // TODO: check for returned future
      state.didUpdateComponent(oldComponent);
    } finally {
      _debugSetAllowIgnoredCallsToMarkNeedsBuild(false);
    }
    super.didUpdate(oldComponent);
  }

  @override
  void activate() {
    super.activate();
    state.activate();
    assert(_lifecycleState == _ElementLifecycle.active);
    markNeedsBuild();
  }

  @override
  void deactivate() {
    state.deactivate();
    super.deactivate();
  }

  @override
  void unmount() {
    super.unmount();
    state.dispose();
    assert(state._debugLifecycleState == _StateLifecycle.defunct);
    state._element = null;
    _state = null;
  }

  bool _didChangeDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didChangeDependencies = true;
  }
}

class ProxyElement extends Element {
  ProxyElement(ProxyComponent super.component);

  @protected
  Iterable<Element> get children => _children!.where((Element child) => !_forgottenChildren.contains(child));

  List<Element>? _children;
  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  bool get debugDoingBuild => false;

  @override
  void mount(Element? parent, Element? prevSibling) {
    super.mount(parent, prevSibling);
    assert(_children == null);
  }

  @override
  void didMount() {
    rebuild();
    super.didMount();
  }

  @override
  bool shouldRebuild(ProxyComponent newComponent) {
    return true;
  }

  @override
  void performRebuild() {
    _dirty = false;

    var comp = (component as ProxyComponent);
    var newComponents = comp.children ?? [if (comp.child != null) comp.child!];

    _children = updateChildren(_children ?? [], newComponents, forgottenChildren: _forgottenChildren);
    _forgottenChildren.clear();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    for (var child in _children ?? []) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(_children != null);
    assert(_children!.contains(child));
    assert(!_forgottenChildren.contains(child));
    _forgottenChildren.add(child);
    super.forgetChild(child);
  }
}

class InheritedElement extends ProxyElement {
  InheritedElement(InheritedComponent super.component);

  @override
  InheritedComponent get component => super.component as InheritedComponent;

  final Map<Element, Object?> _dependents = HashMap<Element, Object?>();

  @override
  void _updateInheritance() {
    assert(_lifecycleState == _ElementLifecycle.active);
    final Map<Type, InheritedElement>? incomingElements = _parent?._inheritedElements;
    if (incomingElements != null) {
      _inheritedElements = HashMap<Type, InheritedElement>.from(incomingElements);
    } else {
      _inheritedElements = HashMap<Type, InheritedElement>();
    }
    _inheritedElements![component.runtimeType] = this;
  }

  @protected
  Object? getDependencies(Element dependent) {
    return _dependents[dependent];
  }

  @protected
  void setDependencies(Element dependent, Object? value) {
    _dependents[dependent] = value;
  }

  @protected
  void updateDependencies(Element dependent, Object? aspect) {
    setDependencies(dependent, null);
  }

  @override
  void didUpdate(covariant InheritedComponent oldComponent) {
    if (component.updateShouldNotify(oldComponent)) {
      notifyClients(oldComponent);
    }
    super.didUpdate(oldComponent);
  }

  @protected
  void notifyClients(covariant InheritedComponent oldComponent) {
    assert(_debugCheckOwnerBuildTargetExists('notifyClients'));
    for (final Element dependent in _dependents.keys) {
      notifyDependent(oldComponent, dependent);
    }
  }

  @protected
  void notifyDependent(covariant InheritedComponent oldComponent, Element dependent) {
    dependent.didChangeDependencies();
  }

  @protected
  @mustCallSuper
  void didRebuildDependent(Element dependent) {
    assert(_dependents.containsKey(dependent));
  }

  @protected
  @mustCallSuper
  void deactivateDependent(Element dependent) {
    assert(_dependents.containsKey(dependent));
    _dependents.remove(dependent);
  }
}
