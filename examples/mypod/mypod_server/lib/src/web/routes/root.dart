import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';
import 'package:serverpod/serverpod.dart';

import '../../../components/root.dart';

class RootRoute extends JasprRoute {
  @override
  Future<Component> build(Session session, HttpRequest request) async {
    return RootComponent();
  }
}
