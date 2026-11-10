@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

void main() {
  group('open attribute', () {
    late void Function(void Function() cb) setState;

    testClient('should keep a dialog opened with showModal() open and modal on rebuild', (tester) async {
      final dialogKey = GlobalNodeKey<HTMLDialogElement>();
      final outsideKey = GlobalNodeKey<HTMLButtonElement>();
      var label = 'Save';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return div([
              button(key: outsideKey, [Component.text('Outside')]),
              dialog(key: dialogKey, [Component.text(label)]),
            ]);
          },
        ),
      );

      final node = dialogKey.currentNode!;
      node.showModal();

      setState(() => label = 'Saving');
      await pumpEventQueue();

      expect(node.textContent, 'Saving');
      expect(node.open, isTrue);
      expect(node.matches(':modal'), isTrue);

      node.close();

      expect(node.open, isFalse);
      expect(node.matches(':modal'), isFalse);

      outsideKey.currentNode!.focus();
      expect(document.activeElement, outsideKey.currentNode);
    });

    testClient('should keep a dialog opened with show() open on rebuild', (tester) async {
      final dialogKey = GlobalNodeKey<HTMLDialogElement>();
      var label = 'Save';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return dialog(key: dialogKey, [Component.text(label)]);
          },
        ),
      );

      final node = dialogKey.currentNode!;
      node.show();

      setState(() => label = 'Saving');
      await pumpEventQueue();

      expect(node.textContent, 'Saving');
      expect(node.open, isTrue);
    });

    testClient('should keep details opened by the user open on rebuild', (tester) async {
      final detailsKey = GlobalNodeKey<HTMLDetailsElement>();
      var label = 'Idle';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return details(key: detailsKey, [
              summary([Component.text('More')]),
              p([Component.text(label)]),
            ]);
          },
        ),
      );

      final node = detailsKey.currentNode!;
      node.open = true;

      setState(() => label = 'Busy');
      await pumpEventQueue();

      expect(node.querySelector('p')!.textContent, 'Busy');
      expect(node.open, isTrue);
    });

    testClient('should close a dialog when the component stops rendering open', (tester) async {
      final dialogKey = GlobalNodeKey<HTMLDialogElement>();
      var open = true;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return dialog(key: dialogKey, open: open, [Component.text('Content')]);
          },
        ),
      );

      final node = dialogKey.currentNode!;
      expect(node.open, isTrue);

      setState(() => open = false);
      await pumpEventQueue();

      expect(node.open, isFalse);
    });

    testClient('should close details when the component stops rendering open', (tester) async {
      final detailsKey = GlobalNodeKey<HTMLDetailsElement>();
      var open = true;

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return details(key: detailsKey, open: open, [
              summary([Component.text('More')]),
            ]);
          },
        ),
      );

      final node = detailsKey.currentNode!;
      expect(node.open, isTrue);

      setState(() => open = false);
      await pumpEventQueue();

      expect(node.open, isFalse);
    });

    testClient('should still remove an open attribute set from code on other elements', (tester) async {
      final divKey = GlobalNodeKey<HTMLDivElement>();
      var label = 'A';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return div(key: divKey, attributes: {'data-label': label}, []);
          },
        ),
      );

      final node = divKey.currentNode!;
      node.setAttribute('open', '');
      node.setAttribute('data-test', '');

      setState(() => label = 'B');
      await pumpEventQueue();

      expect(node.getAttribute('data-label'), 'B');
      expect(node.hasAttribute('open'), isFalse);
      expect(node.hasAttribute('data-test'), isFalse);
    });

    testClient('should remove a server-rendered open the client does not render when hydrating', (tester) async {
      document.body!.innerHTML =
          '<div><dialog open>Content</dialog><details open><summary>More</summary></details></div>'.toJS;

      final dialogNode = document.querySelector('dialog') as HTMLDialogElement;
      final detailsNode = document.querySelector('details') as HTMLDetailsElement;
      expect(dialogNode.open, isTrue);
      expect(detailsNode.open, isTrue);

      tester.pumpComponent(
        div([
          dialog([Component.text('Content')]),
          details([
            summary([Component.text('More')]),
          ]),
        ]),
      );

      expect(document.querySelector('dialog'), dialogNode);
      expect(document.querySelector('details'), detailsNode);
      expect(dialogNode.open, isFalse);
      expect(detailsNode.open, isFalse);
    });

    testClient('should keep open set after hydration on rebuild', (tester) async {
      document.body!.innerHTML = '<dialog>Save</dialog>'.toJS;

      final node = document.querySelector('dialog') as HTMLDialogElement;
      var label = 'Save';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return dialog([Component.text(label)]);
          },
        ),
      );

      expect(document.querySelector('dialog'), node);
      node.showModal();

      setState(() => label = 'Saving');
      await pumpEventQueue();

      expect(node.textContent, 'Saving');
      expect(node.open, isTrue);
      expect(node.matches(':modal'), isTrue);
    });
  });
}
