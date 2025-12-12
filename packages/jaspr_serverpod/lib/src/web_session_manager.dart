import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:jaspr/jaspr.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:web/web.dart' as web;

import '../jaspr_serverpod.dart';
import 'constants.dart';

const _prefsVersion = '2';

/// The [WebSessionManager] keeps track of and manages the signed-in state of the
/// user. Use the [instance] method to get access to the singleton instance.
/// Users are typically authenticated with Google, Apple, or other methods.
/// Please refer to the documentation to see supported methods. Session
/// information is stored in the local storage of the browser and persists
/// between reloads of the page.
final class WebSessionManager with ChangeNotifier {
  static WebSessionManager? _instance;

  /// The auth module's caller.
  Caller caller;

  /// The key provider, holding the key's of the user, if signed in.
  late WebAuthKeyProvider keyProvider;

  /// Creates a new session manager.
  WebSessionManager({
    required this.caller,
  }) {
    _instance = this;
    assert(
      caller.client.authKeyProvider is WebAuthKeyProvider,
      'The client needs an associated key provider of type WebAuthKeyProvider',
    );
    keyProvider = caller.client.authKeyProvider as WebAuthKeyProvider;
  }

  /// Returns a singleton instance of the session manager
  static Future<WebSessionManager> get instance async {
    assert(
      _instance != null,
      'You need to create a WebSessionManager before the instance method can be called',
    );
    return _instance!;
  }

  UserInfo? _signedInUser;

  /// Returns information about the signed in user or null if no user is
  /// currently signed in.
  UserInfo? get signedInUser => _signedInUser;

  /// Registers the signed in user, updates the [keyManager], and upgrades the
  /// streaming connection if it is open.
  Future<void> registerSignedInUser(
    UserInfo userInfo,
    int authenticationKeyId,
    String authenticationKey,
  ) async {
    _signedInUser = userInfo;
    final key = '$authenticationKeyId:$authenticationKey';

    // Store in key manager.
    web.window.localStorage.setItem('${keyProviderAuthKey}_${keyProvider.runMode}', key);
    _storeSharedPrefs();

    // Update streaming connection, if it's open.
    // ignore: deprecated_member_use
    await caller.client.updateStreamingConnectionAuthenticationKey();
    notifyListeners();
  }

  /// Returns true if the user is currently signed in.
  bool get isSignedIn => signedInUser != null;

  /// Initializes the session manager by reading the current state from
  /// shared preferences. The returned bool is true if the session was
  /// initialized, or false if the server could not be reached.
  Future<bool> initialize() async {
    _loadSharedPrefs();
    return refreshSession();
  }

  /// Signs the user out from their devices.
  /// If [allDevices] is true, signs out from all devices; otherwise, signs out from the current device only.
  /// Returns true if the sign-out is successful.
  Future<bool> _signOut({
    required bool allDevices,
  }) async {
    if (!isSignedIn) return true;

    try {
      if (allDevices) {
        await caller.status.signOutAllDevices();
      } else {
        await caller.status.signOutDevice();
      }

      _signedInUser = null;
      _storeSharedPrefs();
      web.window.localStorage.removeItem('${keyProviderAuthKey}_${keyProvider.runMode}');

      // Must be called after updating the `keyManager`, since it will recover
      // the auth key from it.
      // ignore: deprecated_member_use
      await caller.client.updateStreamingConnectionAuthenticationKey();

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Signs the user out from all connected devices.
  /// Returns true if successful.
  Future<bool> signOutAllDevices() async {
    return _signOut(allDevices: true);
  }

  /// Signs the user out from the current device.
  /// Returns true if successful.
  Future<bool> signOutDevice() async {
    return _signOut(allDevices: false);
  }

  /// Verify the current sign in status with the server and update the UserInfo.
  /// Returns true if successful.
  Future<bool> refreshSession() async {
    try {
      _signedInUser = await caller.status.getUserInfo();
      _storeSharedPrefs();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _loadSharedPrefs() {
    final version = web.window.localStorage.getItem('${sessionManagerKey}_${keyProvider.runMode}_version');
    if (version != _prefsVersion) return;

    final json = web.window.localStorage.getItem('${sessionManagerKey}_${keyProvider.runMode}');
    if (json == null) return;

    _signedInUser = Protocol().deserialize<UserInfo>(jsonDecode(json));

    notifyListeners();
  }

  void _storeSharedPrefs() {
    web.window.localStorage.setItem('${sessionManagerKey}_${keyProvider.runMode}_version', _prefsVersion);
    if (signedInUser == null) {
      web.window.localStorage.removeItem('${sessionManagerKey}_${keyProvider.runMode}');
    } else {
      web.window.localStorage.setItem(
        '${sessionManagerKey}_${keyProvider.runMode}',
        SerializationManager.encode(signedInUser),
      );
    }
  }

  /// Uploads a new user image if the user is signed in. Returns true if upload
  /// was successful.
  Future<bool> uploadUserImage(ByteData image) async {
    if (_signedInUser == null) return false;

    try {
      final success = await caller.user.setUserImage(image);
      if (success) {
        _signedInUser = await caller.status.getUserInfo();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
