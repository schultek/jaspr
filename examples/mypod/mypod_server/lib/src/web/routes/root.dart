import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:mypod_server/src/web/components/root.dart';
import 'package:serverpod/serverpod.dart';

import '../jaspr_route.dart';

class RouteRoot extends JasprRoute {
  @override
  Future<Component> build(Session session, HttpRequest request) async {
    return RootComponent();
  }
}
