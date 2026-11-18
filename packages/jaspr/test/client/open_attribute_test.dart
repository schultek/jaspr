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

    testClient('should close a dialog when open changes to false', (tester) async {
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
      expect(node.getAttribute('open'), '');

      setState(() => open = false);
      await pumpEventQueue();

      expect(node.open, isFalse);
    });

    for (final initialOpen in [null, false]) {
      testClient('should fully close a modal dialog when open is false (was $initialOpen)', (tester) async {
        final dialogKey = GlobalNodeKey<HTMLDialogElement>();
        final outsideKey = GlobalNodeKey<HTMLButtonElement>();
        bool? open = initialOpen;

        tester.pumpComponent(
          StatefulBuilder(
            builder: (context, set) {
              setState = set;
              return div([
                button(key: outsideKey, [Component.text('Outside')]),
                dialog(key: dialogKey, open: open, [Component.text('Content')]),
              ]);
            },
          ),
        );

        final node = dialogKey.currentNode!;
        var closeEvents = 0;
        node.addEventListener('close', ((Event _) => closeEvents++).toJS);
        node.showModal();

        setState(() => open = false);
        await pumpEventQueue();

        expect(node.open, isFalse);
        expect(node.matches(':modal'), isFalse);
        expect(closeEvents, 1);

        outsideKey.currentNode!.focus();
        expect(document.activeElement, outsideKey.currentNode);
      });
    }

    testClient('should close details when open changes to false', (tester) async {
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

    testClient('should close details the user opened when open is false', (tester) async {
      final detailsKey = GlobalNodeKey<HTMLDetailsElement>();
      var label = 'Idle';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return details(key: detailsKey, open: false, [
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

      expect(node.open, isFalse);
    });

    testClient('should reopen details the user closed when open is true', (tester) async {
      final detailsKey = GlobalNodeKey<HTMLDetailsElement>();
      var label = 'Idle';

      tester.pumpComponent(
        StatefulBuilder(
          builder: (context, set) {
            setState = set;
            return details(key: detailsKey, open: true, [
              summary([Component.text('More')]),
              p([Component.text(label)]),
            ]);
          },
        ),
      );

      final node = detailsKey.currentNode!;
      node.open = false;

      setState(() => label = 'Busy');
      await pumpEventQueue();

      expect(node.open, isTrue);
    });

    testClient('should leave a dialog open when open is no longer passed', (tester) async {
      final dialogKey = GlobalNodeKey<HTMLDialogElement>();
      bool? open = true;

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

      setState(() => open = null);
      await pumpEventQueue();

      expect(node.open, isTrue);
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

    testClient('should keep a server-rendered open the client does not pass when hydrating', (tester) async {
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
      expect(dialogNode.open, isTrue);
      expect(detailsNode.open, isTrue);
    });

    testClient('should remove a server-rendered open when the client passes open: false', (tester) async {
      document.body!.innerHTML =
          '<div><dialog open>Content</dialog><details open><summary>More</summary></details></div>'.toJS;

      final dialogNode = document.querySelector('dialog') as HTMLDialogElement;
      final detailsNode = document.querySelector('details') as HTMLDetailsElement;

      tester.pumpComponent(
        div([
          dialog(open: false, [Component.text('Content')]),
          details(open: false, [
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
