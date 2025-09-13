import 'package:jaspr/server.dart';

import 'app.dart';
import 'jaspr_options.dart';

void main() {
  Jaspr.initializeApp(options: defaultJasprOptions);

  runApp(
    Document(
      title: 'Fluttercon Berlin 2024',
      styles: [
        css.import('fonts/fonts.css'),
        css('html, body').styles(
          width: 100.percent,
          minHeight: 100.vh,
          padding: Padding.zero,
          margin: Margin.zero,
          fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
        ),
      ],
      body: App(),
    ),
  );
}
