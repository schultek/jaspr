import 'dart:convert';

final stylesBundleOutputs = {
  'site|lib/styles.bundle.json': jsonEncode([
    {
      'elements': ['colors'],
      'id': ['site', 'lib/colors/theme.dart'],
    },
    {
      'elements': ['Button.styles'],
      'id': ['site', 'lib/components/button.dart'],
    },
    {
      'elements': ['styles', 'styles2'],
      'id': ['site', 'lib/globals.dart'],
    },
    {
      'elements': ['Main.styles', 'Main.styles2'],
      'id': ['site', 'lib/main.dart'],
    },
  ]),
};
