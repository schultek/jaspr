import 'dart:io';

import '../framework/framework.dart';
import 'server_binding.dart';

extension AppContext on BuildContext {
  ServerAppBinding get _binding => binding as ServerAppBinding;

  /// The request url.
  String get url => _binding.request.url.toString();

  /// The HTTP headers with case-insensitive keys.
  ///
  /// If a header occurs more than once in the query string, they are mapped to
  /// by concatenating them with a comma.
  ///
  /// The returned map is unmodifiable.
  Map<String, String> get headers => _binding.request.headers.singleValues;

  /// The HTTP headers with multiple values with case-insensitive keys.
  ///
  /// If a header occurs only once, its value is a singleton list.
  /// If a header occurs with no value, the empty string is used as the value
  /// for that occurrence.
  ///
  /// The returned map and the lists it contains are unmodifiable.
  Map<String, List<String>> get headersAll => _binding.request.headers;

  /// The cookies sent with the request.
  Map<String, String> get cookies => _binding.cookies;

  /// Sets the response header with the given key and value.
  void setHeader(String key, String value) {
    _binding.responseHeaders[key] = [value];
  }

  /// Sets the cookie with the given name in the response.
  void setCookie(
    String name,
    String value, {
    DateTime? expires,
    int? maxAge,
    String? domain,
    String? path,
    bool secure = false,
    bool httpOnly = false,
    SameSite? sameSite,
  }) {
    var cookie = Cookie(name, value)
      ..expires = expires
      ..maxAge = maxAge
      ..domain = domain
      ..path = path
      ..secure = secure
      ..httpOnly = httpOnly
      ..sameSite = sameSite;
    var cookieHeaders = _binding.responseHeaders[HttpHeaders.setCookieHeader] ??= [];
    cookieHeaders.add(cookie.toString());
  }

  /// Sets the response status code.
  void setStatusCode(int statusCode, {String? responseBody}) {
    _binding
      ..responseStatusCode = statusCode
      ..responseErrorBody = responseBody;
  }
}
