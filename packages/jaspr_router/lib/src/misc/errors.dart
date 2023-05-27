/// Thrown when [Router] is used incorrectly.
class RouterError extends Error {
  /// Constructs a [RouterError]
  RouterError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'RouterError: $message';
}
