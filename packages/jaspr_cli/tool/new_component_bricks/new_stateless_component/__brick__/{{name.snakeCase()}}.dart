import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

{{#client}}
@client
{{/client}}
class {{name.pascalCase()}} extends StatelessComponent {
  const {{name.pascalCase()}}({super.key});

  @override
  Component build(BuildContext context) {
    return div([]);
  }

  {{#styles}}
  @css
  List<StyleRule> get styles => [];
  {{/styles}}
}
