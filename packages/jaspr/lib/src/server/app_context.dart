/// @docImport 'dart:typed_data';
library;

import 'dart:io';

import '../framework/framework.dart';
import 'server_binding.dart';

extension AppContext on BuildContext {
  ServerAppBinding get _binding => binding as ServerAppBinding;

  /// The url of the current request.
  String get url => binding.currentUrl;

  /// The HTTP headers of the current request with case-insensitive keys.
  ///
  /// If a header occurs more than once in the query string, they are mapped to
  /// by concatenating them with a comma.
  ///
  /// The returned map is unmodifiable.
  Map<String, String> get headers => _binding.request.headers.singleValues;

  /// The HTTP headers of the current request with multiple values with case-insensitive keys.
  ///
  /// If a header occurs only once, its value is a singleton list.
  /// If a header occurs with no value, the empty string is used as the value
  /// for that occurrence.
  ///
  /// The returned map and the lists it contains are unmodifiable.
  Map<String, List<String>> get headersAll => _binding.request.headers;

  /// The cookies sent with the current request.
  Map<String, String> get cookies => _binding.cookies;

  /// Sets the response header with the given name and value.
  void setHeader(String name, String value) {
    _binding.responseHeaders[name] = [value];
  }

  /// Sets the cookie with the given name and value in the response.
  ///
  /// [name] and [value] must be composed of valid characters according to
  /// RFC 6265.
  void setCookie(
    /// The name of the cookie.
    String name,

    /// The value of the cookie.
    String value, {

    /// The time at which the cookie expires.
    DateTime? expires,

    /// The number of seconds until the cookie expires. A zero or negative value
    /// means the cookie has expired.
    int? maxAge,

    /// The domain that the cookie applies to.
    String? domain,

    /// The path within the `domain` that the cookie applies to.
    String? path,

    /// Whether to only send this cookie on secure connections.
    bool secure = false,

    /// Whether the cookie is only sent in the HTTP request and is not made
    /// available to client side scripts.
    bool httpOnly = true,

    /// Whether the cookie is available from other sites.
    SameSite? sameSite,
  }) {
    final cookie = Cookie(name, value)
      ..expires = expires
      ..maxAge = maxAge
      ..domain = domain
      ..path = path
      ..secure = secure
      ..httpOnly = httpOnly
      ..sameSite = sameSite;
    final cookieHeaders = _binding.responseHeaders[HttpHeaders.setCookieHeader] ??= [];
    cookieHeaders.add(cookie.toString());
  }

  /// Sets the response status code.
  ///
  /// When [responseBody] is provided, it will be used as the response body instead of the rendered html.
  /// Supported types for [responseBody] are [String] and [Uint8List].
  void setStatusCode(int statusCode, {Object? responseBody}) {
    _binding
      ..responseStatusCode = statusCode
      ..overrideBody(responseBody);
  }
}
