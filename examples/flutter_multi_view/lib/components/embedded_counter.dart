import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

import '../constants/theme.dart';
@Import.onWeb('../widgets/counter.dart', show: [#CounterWidget])
import 'embedded_counter.imports.dart' deferred as widget;
import 'pulsing_loader.dart';

class EmbeddedCounter extends StatelessComponent {
  const EmbeddedCounter({this.count = 0, required this.onChange, super.key});

  final int count;
  final Function(int) onChange;

  @override
  Component build(BuildContext context) {
    return FlutterEmbedView.deferred(
      classes: 'flutter-counter',
      styles: Styles(margin: Margin.only(top: 20.px)),
      constraints: ViewConstraints(
        minWidth: cardWidth,
        minHeight: cardHeight,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      loader: PulsingLoader(),
      loadLibrary: widget.loadLibrary(),
      builder: () => widget.CounterWidget(count: count, onChange: onChange),
    );
  }

  @css
  static List<StyleRule> get styles => [
        css('.flutter-counter', [
          css('&').styles(
            display: Display.flex,
            radius: BorderRadius.circular(cardBorderRadius.px),
            backgroundColor: surfaceColor,
          ),
          css('& > div[flt-embedding]').styles(
            opacity: 0,
            transition: Transition('opacity', duration: 400),
          ),
          css('&.active > div[flt-embedding]').styles(opacity: 1),
        ])
      ];
}
