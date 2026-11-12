@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:universal_web/web.dart';

const svgNamespace = 'http://www.w3.org/2000/svg';
const htmlNamespace = 'http://www.w3.org/1999/xhtml';

void main() {
  group('raw text browser test', () {
    testClient('renders html', (tester) async {
      tester.pumpComponent(div([raw('<p>Hello <b>World</b></p>')]));

      final p = document.querySelector('div p')!;
      expect(p.namespaceURI, equals(htmlNamespace));
      expect(p.textContent, equals('Hello World'));
    });

    testClient('renders svg children in the svg namespace', (tester) async {
      tester.pumpComponent(
        svg([raw('<circle r="50" cx="50" cy="50" fill="red" />')]),
      );

      // Parsed as html, `circle` is an unknown element in the xhtml namespace,
      // which the browser lays out as nothing: the circle is in the dom and
      // invisible.
      final circle = document.querySelector('svg circle')!;
      expect(circle.namespaceURI, equals(svgNamespace));
    });

    testClient('renders a nested svg fragment in the svg namespace', (
      tester,
    ) async {
      tester.pumpComponent(
        svg([
          raw('<g id="group"><circle r="10" cx="10" cy="10" /></g>'),
        ]),
      );

      final group = document.querySelector('svg #group')!;
      final circle = document.querySelector('svg #group circle')!;
      expect(group.namespaceURI, equals(svgNamespace));
      expect(circle.namespaceURI, equals(svgNamespace));
    });

    testClient('keeps the svg namespace when hydrating server markup', (
      tester,
    ) async {
      // What the server sent for `svg([raw('<circle .../>')])`, where the html
      // parser put the circle in the svg namespace because it was inside the
      // `<svg>` element.
      document.body!.innerHTML = '<svg><circle r="50" cx="50" cy="50"/></svg>'.toJS;

      tester.pumpComponent(
        svg([raw('<circle r="50" cx="50" cy="50" fill="red" />')]),
      );

      // The raw node is rebuilt rather than hydrated, so the point is that
      // what replaces the server's circle is another svg circle, and only one.
      expect(document.querySelectorAll('svg circle').length, equals(1));
      expect(
        document.querySelector('svg circle')!.namespaceURI,
        equals(svgNamespace),
      );
    });

    testClient('renders an svg element inside html as svg', (tester) async {
      tester.pumpComponent(
        div([raw('<svg><circle r="10" cx="10" cy="10" /></svg>')]),
      );

      // The html parser handles `svg` itself, so this case already worked: it
      // is here to catch a fix that special-cases the namespace too eagerly.
      final root = document.querySelector('div svg')!;
      final circle = document.querySelector('div svg circle')!;
      expect(root.namespaceURI, equals(svgNamespace));
      expect(circle.namespaceURI, equals(svgNamespace));
    });
  });
}
