@TestOn('vm')
library;

import 'dart:convert';

import 'package:jaspr/server.dart';
import 'package:test/test.dart';

import 'without_jaspr_testing_library_app.dart';

void main() {
  group('without jaspr testing library', () {
    test('should resolve the project root and render', () async {
      Jaspr.initializeApp();
      final rendered = await renderComponent(App());
      expect(utf8.decode(rendered.body).contains('Hello'), isTrue);
    });
  });
}
