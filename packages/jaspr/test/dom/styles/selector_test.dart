@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('selector', () {
      test('base', () {
        expect(Selector.tag('div').selector, equals('div'));
        expect(Selector.id('a').selector, equals('#a'));
        expect(Selector.dot('a').selector, equals('.a'));
        expect(Selector.className('a').selector, equals('.a'));
        expect(Selector.attr('a').selector, equals('[a]'));
        expect(Selector.pseudoClass('a').selector, equals(':a'));
        expect(Selector.pseudoElem('a').selector, equals('::a'));
      });

      test('chained', () {
        expect(Selector.tag('div').id('a').dot('b').className('c').selector, equals('div#a.b.c'));
        expect(Selector.tag('div').child(Selector.tag('p')).selector, equals('div > p'));
        expect(Selector.tag('div').descendant(Selector.tag('p')).selector, equals('div p'));
        expect(Selector.tag('div').adjacentSibling(Selector.tag('p')).selector, equals('div + p'));
        expect(Selector.tag('div').sibling(Selector.tag('p')).selector, equals('div ~ p'));
      });
    });
  });
}
