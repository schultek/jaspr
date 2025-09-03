import 'package:backend_dart_frog/components/counter.dart';
import 'package:backend_dart_frog/utils.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) {
  return renderJasprComponent(context, Counter());
}
