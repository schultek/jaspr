import 'package:dart_frog/dart_frog.dart' as f;
import 'package:dart_frog_backend/utils.dart';

var jasprMiddleware = serveJasprApp();

f.Handler middleware(f.Handler handler) {
  return handler.use(jasprMiddleware);
}
