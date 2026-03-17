// ignore_for_file: file_names

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/jaspr_content.dart';

import '../../../../components/code_window/code_block.dart';
import '../components/devex_box.dart';

class Integrate extends StatelessComponent {
  const Integrate({super.key});

  @override
  Component build(BuildContext context) {
    final versions = context.page.data.site['versions'] as Map<String, Object?>? ?? {};

    return DevexBox(
      caption: 'INTEGRATE',
      title: 'Packages and Plugins',
      description: .fragment([
        .text('Import any Dart package from pub.dev or even use '),
        a(href: 'https://pub.dev/packages?q=is%3Aplugin+platform%3Aweb', [
          .text('Flutter web plugins'),
        ]),
        .text(' through Jasprs custom compiler pipeline.'),
      ]),
      preview: div([
        CodeBlock(
          scroll: false,
          source:
              '''
            name: my_awesome_website

            dependencies:
              cloud_firestore: ^6.1.0
              dart_mappable: ^4.6.0
              http: ^1.3.0
              intl: ^0.20.1
              jaspr: ^${versions['latestCore']}
              logging: ^1.3.0
              riverpod: ^3.0.1
              shared_preferences: ^2.5.0
            ''',
          language: 'yaml',
        ),
      ]),
    );
  }
}
