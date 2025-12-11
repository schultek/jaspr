import 'dart:convert';

final stylesBundleOutputs = {
  'site|lib/styles.bundle.json': jsonEncode([
    {
      'elements': ['Component.styles', 'Component.styles2'],
      'id': ['site', 'lib/styles_class.dart'],
    },
    {
      'elements': ['styles', 'styles2'],
      'id': ['site', 'lib/styles_global.dart'],
    },
  ]),
};
