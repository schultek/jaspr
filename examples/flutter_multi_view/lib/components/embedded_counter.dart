import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

@Import.onWeb('../widgets/counter.dart', show: [#CounterWidget])
import 'embedded_counter.imports.dart' deferred as widget;

class EmbeddedCounter extends StatelessComponent {
  const EmbeddedCounter({this.count = 0, required this.onChange, super.key});

  final int count;
  final Function(int) onChange;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield FlutterEmbedView.deferred(
      styles: Styles.box(margin: EdgeInsets.only(top: 2.rem), position: const Position.relative()),
      constraints: ViewConstraints(
        minWidth: 300,
        minHeight: 100,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      loader: div(
        styles: Styles.box(
                width: 100.percent,
                height: 100.percent,
                position: const Position.absolute(),
                radius: BorderRadius.circular(10.px))
            .background(color: Colors.lightGrey),
        [],
      ),
      loadLibrary: widget.loadLibrary(),
      builder: () => widget.CounterWidget(count: count, onChange: onChange),
    );
  }
}
