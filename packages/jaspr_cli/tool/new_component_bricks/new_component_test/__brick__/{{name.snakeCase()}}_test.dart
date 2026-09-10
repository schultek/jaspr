import 'package:jaspr_test/jaspr_test.dart';

import '{{{import}}}';

void main() {
  group('{{name.pascalCase()}}', () {
    testComponents('renders correctly', (tester) async {
      tester.pumpComponent(const {{name.pascalCase()}}());

      // The newly generated component only contains an empty <div>.
      // Update this test to match your component's output, for example:
      //   expect(find.text('Count: 0'), findsOneComponent);
      //   await tester.click(find.tag('button'));
      expect(find.tag('div'), findsOneComponent);
    });
  });
}
