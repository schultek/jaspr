import 'package:jaspr/jaspr.dart';

extension TestBinding on AppBinding {
  static AppBinding? _currentTestBinding;

  static Element? get currentRootElement => _currentTestBinding?.rootElement;

  Future<void> runTest(Future<void> Function() testBody) async {
    _currentTestBinding = this;
    try {
      await testBody();
    } finally {
      _currentTestBinding = null;
    }
  }
}
