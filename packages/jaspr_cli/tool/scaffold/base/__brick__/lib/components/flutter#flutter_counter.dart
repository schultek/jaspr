import 'package:flutter/material.dart' hide BuildContext, EdgeInsets;
import 'package:jaspr/jaspr.dart' hide Text, FontWeight, Color, BorderSide, BorderRadius;
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

class FlutterCounter extends StatelessComponent {
  const FlutterCounter({this.count = 0, required this.onChange, super.key});

  final int count;
  final Function(int) onChange;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterEmbedView(
      styles: Styles.box(minWidth: 18.rem, minHeight: 5.rem, margin: EdgeInsets.only(top: 2.rem)),
      app: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFF01589B)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  onChange(count - 1);
                },
              ),
              const SizedBox(width: 5),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Flutter Counter'),
                  Text('$count', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  onChange(count + 1);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
