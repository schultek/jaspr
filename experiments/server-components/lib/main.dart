import 'dart:math';

import 'package:jaspr/server.dart';
import 'jaspr_options.dart';

import 'counter.dart';
import 'root.dart';
import 'root2.dart';
import 'root3.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(Document(
    title: 'server_components',
    body: div([
      Root(
        child: div([
          Counter(),
          Counter(),
        ]),
      ),
      Root2(
        child: p([text("Server text")]),
      ),
      Root3(
        child: Builder(builder: (context) {
          return span([text("Server text ${Random().nextInt(100)}")]);
        }),
      ),
    ]),
  ));
}
