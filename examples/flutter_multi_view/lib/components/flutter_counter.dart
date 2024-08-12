import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

@Import.onWeb('../widgets/counter.dart', show: [#CounterWidget])
import 'flutter_counter.imports.dart';

class FlutterCounter extends StatelessComponent {
  const FlutterCounter({this.count = 0, required this.onChange, super.key});

  final int count;
  final Function(int) onChange;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterEmbedView(
      //styles: Styles.box(width: 18.rem, height: 5.rem, margin: EdgeInsets.only(top: 2.rem)),
      constraints: ViewConstraints(
        minWidth: 300,
        minHeight: 100,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      loader: div(
        styles: Styles.box(width: 18.rem, height: 5.rem, margin: EdgeInsets.only(top: 2.rem))
            .background(color: Colors.black),
        [],
      ),
      app: kIsWeb ? CounterWidget(count: count, onChange: onChange) : null,
    );
  }
}
