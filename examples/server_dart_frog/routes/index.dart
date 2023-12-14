import 'package:dart_frog/dart_frog.dart';

/// A standard route from dart_frog.
/// Nothing jaspr-ish going on.
Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}
