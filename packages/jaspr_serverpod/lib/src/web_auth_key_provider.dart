import 'package:serverpod_client/serverpod_client.dart';
import 'package:web/web.dart' as web;

import 'constants.dart';

/// Implementation of a Serverpod [ClientAuthKeyProvider] specifically for
/// the web. Authentication key is stored in local storage.
final class WebAuthKeyProvider implements ClientAuthKeyProvider {
  /// The run mode of the Serverpod.
  final String runMode;

  /// Creates a new authentication key provider.
  WebAuthKeyProvider({
    this.runMode = 'production',
  });

  @override
  Future<String?> get authHeaderValue {
    final key = web.window.localStorage.getItem('${keyProviderAuthKey}_$runMode');
    return Future.value(key != null ? wrapAsBasicAuthHeaderValue(key) : null);
  }
}
