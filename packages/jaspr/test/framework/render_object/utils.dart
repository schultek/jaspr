import 'dart:async';

import 'package:jaspr_test/jaspr_test.dart';
import 'package:meta/meta.dart';

import '../../utils/mock_render_object.dart';

@isTest
void testRenderObjectMock(String description, FutureOr<void> Function(MockRenderObjectBinding binding) run) {
  test(description, () async {
    final binding = MockRenderObjectBinding('/', true);
    final root = binding.root;

    autoMockChildren(root);

    await run(binding);

    verifyNoMoreRenderInteractions(root);
  });
}
