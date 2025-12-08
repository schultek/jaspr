import 'dart:async';

import '../../server.dart';

Expando<TaskChain> _asyncBuildLocks = Expando();

extension AsyncElement on Element {
  /// Can be set by the element to signal that the first build should be performed asynchronous.
  TaskChain? get _asyncBuildLock => _asyncBuildLocks[this];
  set _asyncBuildLock(TaskChain? chain) => _asyncBuildLocks[this] = chain;
}

class AsyncBuildOwner extends BuildOwner {
  @override
  void completeInitialBuild(Element element, void Function() buildCallback) async {
    await element._asyncBuildLock?.asFuture;
    super.completeInitialBuild(element, buildCallback);
  }

  @override
  void performRebuildOn(Element child) {
    final parentAsyncBuildLock = child.parent?._asyncBuildLock;
    if (child is! RenderObjectElement) {
      child._asyncBuildLock = parentAsyncBuildLock;
    }

    final chain = TaskChain.start()
        .then(() => child.performRebuild())
        // Wait on children
        .then(() => child._asyncBuildLock)
        // Wait on previous siblings
        .then(() => parentAsyncBuildLock)
        .then(() => child.didRebuild());

    child.parent?._asyncBuildLock = chain;
  }
}

class TaskChain {
  TaskChain._() : _done = false;
  TaskChain.start() : _done = true;

  bool _done;
  final Set<void Function()> _listeners = {};

  void _complete() {
    _done = true;
    for (final l in _listeners) {
      l();
    }
  }

  void _then(void Function() fn) {
    if (_done) {
      fn();
    } else {
      _listeners.add(fn);
    }
  }

  TaskChain then(Object? Function() fn) {
    final c = TaskChain._();
    _then(() {
      final r = fn();
      if (r is Future) {
        r.then((_) {
          c._complete();
        });
      } else if (r is TaskChain) {
        r._then(() {
          c._complete();
        });
      } else {
        c._complete();
      }
    });
    return c;
  }

  Future<void> get asFuture {
    final c = Completer<void>.sync();
    _then(c.complete);
    return c.future;
  }
}
