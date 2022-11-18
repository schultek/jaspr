import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend/utils.dart';

/// The jaspr middleware responsible for serving all additional assets
/// from web/ needed by the rendered components, mainly the compiled .js files.
var jasprMiddleware = serveJasprApp();

/// Provides the middleware to dart_frog.
Handler middleware(Handler handler) {
  return handler.use(jasprMiddleware);
}
