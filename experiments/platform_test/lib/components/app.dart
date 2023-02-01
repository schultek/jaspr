import 'package:jaspr/jaspr.dart';

//import 'dart:io';

@Import.onWeb('dart:html', show: [#window, #HtmlDocument])
@Import.onServer('dart:io', show: [#Platform])
import 'app.imports.dart';

part 'app.g.dart';

@app
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    String op = '';
    if (kIsWeb) {
      print(window.name);
      if (window.document is HtmlDocumentOrStubbed) {
        window.alert('Hi Jaspr');
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
