import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';
import 'package:serverpod/serverpod.dart';

import '/components/home.dart';

class RootRoute extends JasprRoute {
  @override
  Future<Component> build(Session session, HttpRequest request) async {
    return Document(
      title: "Built with Serverpod & Jaspr",
      head: [
        link(rel: "stylesheet", href: "/css/style.css"),
      ],
      body: Home(),
    );
  }
}
