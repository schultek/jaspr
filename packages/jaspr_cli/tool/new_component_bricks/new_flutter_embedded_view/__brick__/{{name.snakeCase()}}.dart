import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

// The flutter widget is only imported on the web (as the server cannot import flutter)
// and is imported as a deferred library, to not block hydration of the remaining website.
@Import.onWeb('../widgets/{{flutterAppName.snakeCase()}}.dart', show: [#{{flutterAppName.pascalCase()}}])
import '{{name.snakeCase()}}.imports.dart' deferred as flutter_app;

class {{name.pascalCase()}} extends StatelessComponent {
  const {{name.pascalCase()}}({super.key});


  @override
  Component build(BuildContext context) {
    return FlutterEmbedView.deferred(
      styles: Styles(margin: .only(top: 2.rem)),
      // We need to set constraints as the flutter view cannot dynamically size itself.
      constraints: ViewConstraints(
        minWidth: 300,
        minHeight: 100,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
      ),
      // The [FlutterEmbedView.deferred] component will take care of loading
      // the widget and initializing flutter.
      loadLibrary: flutter_app.loadLibrary(),
      builder: () => flutter_app.{{flutterAppName.pascalCase()}}(),
    );
  }
}
