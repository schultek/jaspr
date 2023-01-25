import 'package:jaspr/jaspr.dart';

@Import.onWeb('dart:html', show: [#window, #HtmlDocument])
@Import.onServer('dart:io', show: [#Platform])
import 'app.import.dart';

part 'app.g.dart';

@app
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    String op = '';
    if (kIsWeb) {
      print(window.name);
      if (window.document is HtmlDocumentOrStubbed) {
        window.alert('His');
      }
    } else {
      op = Platform.operatingSystem;
    }
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World $op'),
    );
  }
}