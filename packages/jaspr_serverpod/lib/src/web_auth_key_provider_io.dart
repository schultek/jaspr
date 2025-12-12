abstract final class WebAuthKeyProvider {
  factory WebAuthKeyProvider({
    String runMode = 'production',
  }) {
    throw UnsupportedError('WebAuthKeyProvider is not available on the server.');
  }
}
