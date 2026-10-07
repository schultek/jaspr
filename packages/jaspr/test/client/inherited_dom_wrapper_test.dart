@TestOn('browser')
library;

import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('Component.apply', () {
    testClient('applies inherited classes after global-key reparenting', (tester) async {
      var moved = false;
      late void Function(void Function() cb) setState;
      final movable = button(key: GlobalKey(), classes: 'own', []);

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return .fragment([
              div(id: 'source', [if (!moved) movable]),
              .apply(
                target: const .descendantWith(tag: 'button'),
                classes: 'applied',
                child: div(id: 'destination', [if (moved) movable]),
              ),
            ]);
          },
        ),
      );

      final btn = window.document.querySelector('button')!;
      expect(btn.className, 'own');

      // The same component is moved, so only the new inherited params make it render again.
      setState(() => moved = true);
      await pumpEventQueue();
      expect(window.document.querySelector('#destination > button'), equals(btn));
      expect(btn.className, 'own applied');
    });
  });
}
