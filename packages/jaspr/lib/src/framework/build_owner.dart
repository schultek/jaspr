part of framework;

class BuildOwner {
  final List<Element> _dirtyElements = <Element>[];

  Future? _scheduledBuild;

  BuildScheduler? _schedulerContext;

  final _InactiveElements _inactiveElements = _InactiveElements();

  /// Whether [_dirtyElements] need to be sorted again as a result of more
  /// elements becoming dirty during the build.
  ///
  /// This is necessary to preserve the sort order defined by [Element._sort].
  ///
  /// This field is set to null when [performBuild] is not actively rebuilding
  /// the widget tree.
  bool? _dirtyElementsNeedsResorting;

  /// Whether this widget tree is in the build phase.
  ///
  /// Only valid when asserts are enabled.
  bool get debugBuilding => _debugBuilding;
  bool _debugBuilding = false;

  void scheduleBuildFor(Element element) {
    assert(!ComponentsBinding.instance!.isFirstBuild);
    assert(element.dirty, 'scheduleBuildFor() called for a widget that is not marked as dirty.');

    if (element._inDirtyList) {
      _dirtyElementsNeedsResorting = true;
      return;
    }
    _scheduledBuild ??= Future(performBuild);
    if (_schedulerContext == null || element._scheduler!.depth < _schedulerContext!.depth) {
      _schedulerContext = element._scheduler;
    }

    _dirtyElements.add(element);
    element._inDirtyList = true;
  }

  void performBuild() {
    assert(!ComponentsBinding.instance!.isFirstBuild);

    assert(_schedulerContext != null);
    assert(!_debugBuilding);

    assert(() {
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

      _schedulerContext!.view.update();
      _schedulerContext = null;

      _inactiveElements._unmountAll();

      _scheduledBuild = null;

      assert(_debugBuilding);
      assert(() {
        _debugBuilding = false;
        return true;
      }());
    }
  }
}
