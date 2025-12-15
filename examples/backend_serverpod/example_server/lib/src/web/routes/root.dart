import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart' hide Request;
import 'package:jaspr_serverpod/jaspr_serverpod.dart';
import 'package:serverpod/serverpod.dart';

import '/components/home.dart';

class RootRoute extends JasprRoute {
  @override
  Future<Component> build(Session session, Request request) async {
    return Document(
      title: "Built with Serverpod & Jaspr",
      head: [link(rel: "stylesheet", href: "/css/style.css")],
      body: Home(),
    );
  }
}
