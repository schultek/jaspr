const configs = [
  TestConfig(
    name: 'basic',
    files: {
      'pubspec.yaml',
      'README.md',
      'lib/main.dart',
      'lib/styles.dart',
      'lib/jaspr_options.dart',
      'lib/components/app.dart',
    },
    resources: {
      '/',
      '/main.clients.dart.js',
      '/components/app.client.dart.js',
    },
    outputs: {
      'app',
      'web/main.clients.dart.js',
      'web/main.clients.dart.js_1.part.js',
      'web/components/app.client.dart.js',
    },
    hasClient: true,
    hasServer: true,
  ),
  TestConfig(
    name: 'client',
    files: {
      'pubspec.yaml',
      'README.md',
      'lib/app.dart',
      'web/main.dart',
      'web/index.html',
      'web/styles.css',
    },
    resources: {
      '/',
      '/main.dart.js',
      '/styles.css',
    },
    outputs: {
      'index.html',
      'main.dart.js',
      'styles.css',
    },
    hasClient: true,
    hasServer: false,
  ),
  TestConfig(
    name: 'server',
    files: {
      'pubspec.yaml',
      'README.md',
      'lib/main.dart',
      'lib/styles.dart',
      'lib/components/app.dart',
    },
    resources: {
      '/',
    },
    outputs: {
      'app',
    },
    hasClient: false,
    hasServer: true,
  )
];

class TestConfig {
  final String name;
  final Set<String> files;
  final Set<String> resources;
  final Set<String> outputs;

  final bool hasClient;
  final bool hasServer;

  const TestConfig({
    required this.name,
    required this.files,
    required this.resources,
    required this.outputs,
    required this.hasClient,
    required this.hasServer,
  });
}
