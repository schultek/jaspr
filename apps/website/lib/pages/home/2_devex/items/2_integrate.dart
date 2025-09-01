// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../../components/code_window/code_block.dart';
import '../components/devex_box.dart';

class Integrate extends StatelessComponent {
  const Integrate({super.key});

  @override
  Component build(BuildContext context) {
    return DevexBox(
      caption: 'INTEGRATE',
      title: 'Packages and Plugins',
      description: fragment([
        text('Import any Dart package from pub.dev or even use '),
        b([
          a(
            href: 'https://pub.dev/packages?q=is%3Aplugin+platform%3Aweb',
            classes: 'animated-underline',
            [text('Flutter web plugins')],
          )
        ]),
        text(' through Jasprs custom compiler pipeline.'),
      ]),
      preview: div([
        CodeBlock(
          scroll: false,
          source: '''
                name: my_awesome_website

                dependencies:
                  cloud_firestore: ^5.6.2
                  dart_mappable: ^4.3.0
                  http: ^1.3.0
                  intl: ^0.19.0
                  jaspr: ^0.19.0
                  logging: ^1.3.0
                  riverpod: ^2.6.1
                  shared_preferences: ^2.4.0
                ''',
          language: 'yaml',
        ),
      ]),
    );
  }
}
