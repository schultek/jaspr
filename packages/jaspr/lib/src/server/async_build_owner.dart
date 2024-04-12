import 'dart:async';

import '../../browser.dart';

Expando<TaskChain> _asyncBuildLocks = Expando();

extension AsyncElement on Element {
  /// Can be set by the element to signal that the first build should be performed asynchronous.
  TaskChain? get _asyncBuildLock => _asyncBuildLocks[this];
  set _asyncBuildLock(TaskChain? chain) => _asyncBuildLocks[this] = chain;
}

class AsyncBuildOwner extends BuildOwner {
  @override
  Future<void> performInitialBuild(Element element) async {
    await super.performInitialBuild(element);
    await element._asyncBuildLock.asFuture;
  }

  @override
  void performRebuildOn(Element child, void Function() whenComplete) {
    var parentAsyncBuildLock = child.parent?._asyncBuildLock;

    var chain = TaskChain.start()
        .then(() => child.performRebuild())
        .then(() => whenComplete())
        .then(() => child._asyncBuildLock)
        .then(() => parentAsyncBuildLock)
        .then(() => child.attachRenderObject());

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
}

extension TaskChainThen on TaskChain? {
  TaskChain? then(Object? Function() fn) {
    var chain = this;
    if (chain == null || chain._done) {
      var r = fn();
      if (r is Future) {
        var c = TaskChain._();
        r.then((_) {
          c._complete();
        });
        return c;
      } else if (r is TaskChain && !r._done) {
        return r;
      } else {
        return null;
      }
    } else {
      var c = TaskChain._();
      chain._listeners.add(() {
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
  }

  Future<void> get asFuture {
    if (this == null) {
      return Future.value();
    } else {
      var c = Completer.sync();
      this!._then(c.complete);
      return c.future;
    }
  }
}
