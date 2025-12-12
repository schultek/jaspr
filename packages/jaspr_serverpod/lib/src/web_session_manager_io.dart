import 'dart:typed_data';

abstract final class WebSessionManager {
  factory WebSessionManager({
    required Object? caller,
  }) {
    throw UnsupportedError('WebSessionManager is not available on the server.');
  }

  static Future<WebSessionManager> get instance =>
      throw UnsupportedError('WebSessionManager is not available on the server.');

  dynamic get signedInUser;

  Future<void> registerSignedInUser();

  bool get isSignedIn;

  Future<bool> initialize();

  Future<bool> signOutAllDevices();

  Future<bool> signOutDevice();

  Future<bool> refreshSession();

  Future<bool> uploadUserImage(ByteData image);
}
