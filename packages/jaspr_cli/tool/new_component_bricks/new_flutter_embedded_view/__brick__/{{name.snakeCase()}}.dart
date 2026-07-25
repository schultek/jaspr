import 'package:jaspr/jaspr.dart';
import 'package:jaspr_flutter_embed/jaspr_flutter_embed.dart';

{{#static_or_server}}
// Import your Flutter app widget, but only on web.
@Import.onWeb('{{flutterAppName.snakeCase()}}.dart', show: [#{{flutterAppName.pascalCase()}}]);
import '<current_filename>.imports.dart';
{{/static_or_server}}
{{^static_or_server}}
// Import your flutter app widget.
import '{{flutterAppName.snakeCase()}}.dart';
{{/static_or_server}}
class {{name.pascalCase()}} extends StatelessComponent {
  const {{name.pascalCase()}}({super.key});


  @override
  Component build(BuildContext context) {
    return FlutterEmbedView(
      // You can provide a loader that will be shown while the Flutter app loads
      // loader: MyCustomLoader(),
      widget: {{#static_or_server}}kIsWeb ?{{/static_or_server}} {{flutterAppName.pascalCase()}}(
        // You can pass any properties of callbacks to your widget
      ){{#static_or_server}} : null{{/static_or_server}},
    );
  }
}
