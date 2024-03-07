import 'package:flutter/material.dart' as flt;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

class EmbeddedCounter extends StatelessComponent {
  const EmbeddedCounter({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterEmbedView(
      app: flt.MaterialApp(
        home: flt.Scaffold(
          body: flt.Text('Flutter'),
        ),
      ),
    );
  }
}
