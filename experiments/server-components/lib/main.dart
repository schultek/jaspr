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
      // Root(
      //   child: div([
      //     Counter(),
      //     Counter(),
      //   ]),
      // ),
      // Root2(
      //   child: p([text("Server text")]),
      // ),
      Root3(
        children: [
           span([text("Server Child 1")]),
           span([text("Server Child 2")]),
           span([text("Server Child 3")]),
           span([text("Server Child 4")]),
        ],
        children2: {
          "42": div([text("The answer to life, the universe and everything")]),
          "7": div([text("A lucky number")]),
          "13": div([text("An unlucky number")]),
          "69": div([text("A funny number")]),
        }
      ),
    ]),
  ));
}