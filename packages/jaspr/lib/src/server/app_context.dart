import 'dart:io';

import '../framework/framework.dart';
import 'server_binding.dart';

extension AppContext on BuildContext {
  ServerAppBinding get _binding => binding as ServerAppBinding;

  String get url => _binding.request.url.toString();

  Map<String, String> get headers => _binding.request.headers.singleValues;

  Map<String, List<String>> get headersAll => _binding.request.headers;

  Map<String, String> get cookies => _binding.cookies;

  void setHeader(String key, String value) {
    _binding.responseHeaders[key] = [value];
  }

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

  void setStatusCode(int statusCode, {String? responseBody}) {
    _binding
      ..responseStatusCode = statusCode
      ..responseErrorBody = responseBody;
  }
}
