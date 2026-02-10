import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

import 'package:flutter/material.dart' deferred as flt show MaterialApp, Text;

class About extends StatelessComponent {
  const About({super.key});

  @override
  Component build(BuildContext context) {
    return section([
      FlutterEmbedView.deferred(
        styles: Styles(width: 100.percent, height: 100.percent),
        loadLibrary: flt.loadLibrary(),
        builder: () => flt.MaterialApp(
          home: flt.Text('Hello World'),
        ),
      ),
    ]);
  }
}
