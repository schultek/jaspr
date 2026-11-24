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
    final lock = element._asyncBuildLock;
    await lock?.asFuture;

    // A step that threw is reported here rather than left to unwind, and the
    // build is completed either way. Skipping [buildCallback] would leave the
    // frame -- and on the server the HTTP response waiting on it -- pending
    // forever.
    if (lock?._failure case final failure?) {
      element.binding.reportBuildError(element, failure.error, failure.stackTrace);
    }

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

  /// Callbacks waiting on this chain, run in insertion order once it completes.
  final List<void Function()> _listeners = [];

  /// The failure this chain completed with, if any.
  ({Object error, StackTrace stackTrace})? _failure;

  void _complete([({Object error, StackTrace stackTrace})? failure]) {
    if (_done) return;
    _done = true;
    _failure = failure;
    for (final l in _listeners) {
      l();
    }
    _listeners.clear();
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
      // Skip this step if an earlier one failed, and carry the failure down the
      // chain, so that whoever awaits the end of it is told instead of waiting
      // on a chain that can never complete.
      if (_failure case final failure?) {
        c._complete(failure);
        return;
      }

      final Object? r;
      try {
        r = fn();
      } catch (e, st) {
        c._complete((error: e, stackTrace: st));
        return;
      }

      if (r is Future) {
        r.then(
          (_) => c._complete(),
          onError: (Object e, StackTrace st) => c._complete((error: e, stackTrace: st)),
        );
      } else if (r case final TaskChain chain) {
        chain._then(() => c._complete(chain._failure));
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
