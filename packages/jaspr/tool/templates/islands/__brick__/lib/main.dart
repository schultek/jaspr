// the entry point for the server

// server-specific import, exposes [Document]
import 'package:jaspr/server.dart';
import 'components/app.dart';

void main() {
  // runs the server and serves the provided component
  // - comes with in hotreload during development when using 'jaspr serve'
  runApp(MyDocument());
}

// root component used to set up the document in 'islands' mode
class MyDocument extends StatelessComponent {
  const MyDocument({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // scaffolds the main document (<html>, <head>, <body>)
    // and selects the 'islands' mode
    // - only specified **Island** components will be compiled as part of the javascript bundle and
    //   hydrated on the client
    // - all client-side code will be auto-generated inside the /web directory
    yield Document.islands(
      title: '{{name}}',
      styles: [
        StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
        StyleRule(
          selector: const Selector.list([Selector.tag('html'), Selector.tag('body')]),
          styles: Styles.combine([
            const Styles.text(
              fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
            ),
            Styles.box(
              width: 100.percent,
              height: 100.percent,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
          ]),
        ),
      ],
      // renders the [App] component inside the <body>
      body: App(),
    );
  }
}