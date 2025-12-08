part of 'framework.dart';

class BuildOwner {
  final List<Element> _dirtyElements = <Element>[];

  bool _scheduledBuild = false;

  // ignore: prefer_final_fields
  bool _isFirstBuild = false;
  bool get isFirstBuild => _isFirstBuild;

  final _InactiveElements _inactiveElements = _InactiveElements();

  /// Whether [_dirtyElements] need to be sorted again as a result of more
  /// elements becoming dirty during the build.
  ///
  /// This is necessary to preserve the sort order defined by [Element._sort].
  ///
  /// This field is set to null when [performBuild] is not actively rebuilding
  /// the widget tree.
  bool? _dirtyElementsNeedsResorting;

  void scheduleBuildFor(Element element) {
    assert(!isFirstBuild);
    assert(element.dirty, 'scheduleBuildFor() called for a widget that is not marked as dirty.');

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

  /// Whether this widget tree is in the build phase.
  ///
  /// Only valid when asserts are enabled.
  bool get debugBuilding => _debugBuilding;
  bool _debugBuilding = false;
  Element? _debugCurrentBuildTarget;

  int _debugStateLockLevel = 0;
  bool get _debugStateLocked => _debugStateLockLevel > 0;

  /// Establishes a scope in which calls to [State.setState] are forbidden, and
  /// calls the given `callback`.
  ///
  /// This mechanism is used to ensure that, for instance, [State.dispose] does
  /// not call [State.setState].
  Future<void> lockState(dynamic Function() callback) async {
    assert(_debugStateLockLevel >= 0);
    assert(() {
      _debugStateLockLevel += 1;
      return true;
    }());
    try {
      final res = callback() as dynamic;
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

  Future<void> performInitialBuild(Element element, void Function() completeBuild) async {
    assert(_debugStateLockLevel >= 0);
    assert(!_debugBuilding);

    assert(() {
      _debugStateLockLevel += 1;
      _debugBuilding = true;
      return true;
    }());

    _isFirstBuild = true;

    element.mount(null, ElementSlot(0, null));
    element.didMount();

    completeInitialBuild(element, () {
      _isFirstBuild = false;

      assert(_debugBuilding);
      assert(() {
        _debugBuilding = false;
        _debugStateLockLevel -= 1;
        return true;
      }());

      completeBuild();
    });
  }

  void completeInitialBuild(Element element, void Function() buildCallback) {
    buildCallback();
  }

  /// Rebuilds [child] and correctly accounts for any asynchronous operations that can
  /// occur during the initial build of the app.
  /// We want the component and element apis to stay synchronous, so this delays
  /// the execution of [child.performRebuild()] instead of calling it directly.
  void performRebuildOn(Element child) {
    final Object? result = child.performRebuild() as dynamic;
    assert(
      result is! Future,
      '${child.runtimeType}.performBuild() returned a Future while rebuilding.\n\n'
      'Only server builds are allowed to be asynchronous.',
    );
    child.didRebuild();
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
          print('Error on rebuilding component: $e');
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
        if (_dirtyElements.any(
          (Element element) => element._lifecycleState == _ElementLifecycle.active && element.dirty,
        )) {
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
