import 'package:dart_frog/dart_frog.dart';
import 'package:server_dart_frog/components/hello.dart';
import 'package:server_dart_frog/utils.dart';

Future<Response> onRequest(RequestContext context, String name) {
  return renderJasprComponent(context, Hello(name: name));
}
