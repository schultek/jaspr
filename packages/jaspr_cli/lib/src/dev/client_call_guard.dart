import 'dart:async';

/// Limits how long the dev workflow waits for a single client.
///
/// Reloads are applied to all clients one after another, and each build waits
/// for the previous reload to finish. A client that never answers (e.g. a phone
/// with the screen turned off or a frozen background tab) would otherwise block
/// all following reloads until its connection is closed.
///
/// When a call doesn't complete within [timeout], [run] returns `null` and the
/// client is treated as unresponsive: further calls are skipped until all
/// timed out calls have completed.
class ClientCallGuard {
  ClientCallGuard({this.timeout = const Duration(seconds: 10), this.onUnresponsive, this.onResponsive});

  final Duration timeout;

  /// Called when a call times out and the client is marked as unresponsive.
  final void Function()? onUnresponsive;

  /// Called when all timed out calls have completed and the client is responsive again.
  final void Function()? onResponsive;

  // Calls can overlap (e.g. an automatic reload and a keyboard shortcut),
  // so more than one call can time out before the client responds again.
  int _timedOutCalls = 0;
  bool get isUnresponsive => _timedOutCalls > 0;

  /// Runs [call] and returns its result, or `null` if the client is
  /// unresponsive or [call] doesn't complete within [timeout].
  ///
  /// Errors of [call] are forwarded, including a [TimeoutException] it throws itself.
  Future<T?> run<T>(Future<T?> Function() call) async {
    if (isUnresponsive) return null;

    final future = call();
    // The returned future may be typed as non-nullable at runtime, so it couldn't complete with `null` on timeout.
    return future
        .then<T?>((value) => value)
        .timeout(
          timeout,
          onTimeout: () {
            _trackTimedOutCall(future);
            return null;
          },
        );
  }

  void _trackTimedOutCall(Future<Object?> future) {
    if (_timedOutCalls++ == 0) onUnresponsive?.call();
    unawaited(
      future.then<void>((_) {}, onError: (_) {}).whenComplete(() {
        if (--_timedOutCalls == 0) onResponsive?.call();
      }),
    );
  }
}
