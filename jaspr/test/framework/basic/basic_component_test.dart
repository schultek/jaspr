import 'package:jaspr_test/jaspr_test.dart';

import 'basic_app.dart';

void main() {
  group('basic component test', () {
    late ComponentTester tester;

    setUp(() {
      TestComponentsBinding.setUp();
      tester = TestComponentsBinding.instance.tester;
    });

    test('should render component', () async {
      await tester.pumpComponent(App());

      expect(find.text('Count: 0'), findsOneComponent);

      await tester.click(find.tag('button'));

      expect(find.text('Count: 1'), findsOneComponent);
    });
  });
}
