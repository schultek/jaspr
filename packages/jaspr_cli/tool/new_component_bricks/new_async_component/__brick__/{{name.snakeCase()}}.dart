import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';

class {{name.pascalCase()}} extends AsyncStatelessComponent {
  const {{name.pascalCase()}}({super.key});

  @override
  Future<Component> build(BuildContext context) async {
    return div([]);
  }

  {{#styles}}
  @css
  List<StyleRule> get styles => [];
  {{/styles}}
}
