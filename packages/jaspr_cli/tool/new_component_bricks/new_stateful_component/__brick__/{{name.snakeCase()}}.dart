import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
{{#client}}
@client
{{/client}}
class {{name.pascalCase()}} extends StatefulComponent {
  const {{name.pascalCase()}}({super.key});

  @override
  State<{{name.pascalCase()}}> createState() => _{{name.pascalCase()}}State();
}

class _{{name.pascalCase()}}State extends State<{{name.pascalCase()}}> {

  {{#client}}
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Run client-side initialization logic here
    } else {
      // Run server-side initialization logic here
    }
  }
  {{/client}}

  @override
  Component build(BuildContext context) {
    return div([]);
  }

  {{#styles}}
  @css
  List<StyleRule> get styles => [];
  {{/styles}}
}
