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
  Future<void> performInitialBuild(Element element, Future<void> Function() completeBuild) {
    return super.performInitialBuild(element, () async {
      await element._asyncBuildLock?.asFuture;
      return completeBuild();
    });
  }

  @override
  void performRebuildOn(Element child, void Function() whenComplete) {
    var parentAsyncBuildLock = child.parent?._asyncBuildLock;

    var chain = TaskChain.start()
        .then(() => child.performRebuild())
        .then(() => whenComplete())
        // Wait on previous siblings
        .then(() => parentAsyncBuildLock)
        .then(() => child.attachRenderObject())
        // Wait on children
        .then(() => child._asyncBuildLock);

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
    for (var l in _listeners) {
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
    var c = TaskChain._();
    _then(() {
      var r = fn();
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
    var c = Completer.sync();
    _then(c.complete);
    return c.future;
  }
}
