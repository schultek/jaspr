import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_backend/components/counter.dart';
import 'package:dart_frog_backend/utils.dart';

Future<Response> onRequest(RequestContext context) {
  return renderJasprComponent(context, Counter());
}
