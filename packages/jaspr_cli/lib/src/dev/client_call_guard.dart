import 'dart:async';

/// Limits how long the dev workflow waits for a single client.
///
/// Reloads are applied to all clients one after another, and each build waits
/// for the previous reload to finish. A client that never answers (e.g. a phone
/// with the screen turned off or a frozen background tab) would otherwise block
/// all following reloads until its connection is closed.
///
/// When a call doesn't complete within [timeout], [run] returns `null` and the
/// client is treated as unresponsive: further calls are skipped until the
/// timed out call completes.
class ClientCallGuard {
  ClientCallGuard({this.timeout = const Duration(seconds: 10), this.onUnresponsive, this.onResponsive});

  final Duration timeout;

  /// Called when a call times out and the client is marked as unresponsive.
  final void Function()? onUnresponsive;

  /// Called when the timed out call completes and the client is responsive again.
  final void Function()? onResponsive;

  bool _isUnresponsive = false;
  bool get isUnresponsive => _isUnresponsive;

  /// Runs [call] and returns its result, or `null` if the client is
  /// unresponsive or [call] doesn't complete within [timeout].
  Future<T?> run<T>(Future<T?> Function() call) async {
    if (_isUnresponsive) return null;

    final future = call();
    try {
      return await future.timeout(timeout);
    } on TimeoutException {
      _isUnresponsive = true;
      onUnresponsive?.call();
      unawaited(
        future.then<void>((_) {}, onError: (_) {}).whenComplete(() {
          _isUnresponsive = false;
          onResponsive?.call();
        }),
      );
      return null;
    }
  }
}
