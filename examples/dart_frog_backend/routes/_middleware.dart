import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend/utils.dart';

var jasprMiddleware = serveJasprApp();

Handler middleware(Handler handler) {
  return handler.use(jasprMiddleware);
}
