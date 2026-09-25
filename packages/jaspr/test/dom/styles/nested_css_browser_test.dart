@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:jaspr/dom.dart';
import 'package:jaspr/src/dom/styles/rules.dart';
import 'package:test/test.dart';
import 'package:universal_web/web.dart';

/// Renders [rules] into a `<style>` element and hands back the element the
/// nested rules are meant to reach.
Element render(List<StyleRule> rules, String html) {
  final style = document.createElement('style')..textContent = rules.render();
  document.head!.append(style);
  addTearDown(() => style.remove());

  final host = document.createElement('div')..innerHTML = html.toJS;
  document.body!.append(host);
  addTearDown(() => host.remove());

  return host;
}

String styleOf(Element element, String property) => window.getComputedStyle(element).getPropertyValue(property);

void main() {
  group('nested css in the browser', () {
    test('a nested selector applies to the element it describes', () {
      final host = render([
        css('.outer', [
          css('&').styles(raw: {'--outer': 'yes'}),
          css('.inner').styles(color: Color.rgb(1, 2, 3)),
        ]),
      ], '<div class="outer"><span class="inner">nested</span></div>');

      final outer = host.querySelector('.outer')!;
      final inner = host.querySelector('.inner')!;

      expect(styleOf(outer, '--outer').trim(), equals('yes'));
      expect(styleOf(inner, 'color'), equals('rgb(1, 2, 3)'));
    });

    test('a nested pseudo-class applies', () {
      final host = render([
        css('.link', [css('&:first-child').styles(fontWeight: FontWeight.bold)]),
      ], '<div><a class="link">first</a><a class="link">second</a></div>');

      final links = host.querySelectorAll('.link');

      expect(styleOf(links.item(0)! as Element, 'font-weight'), equals('700'));
      expect(styleOf(links.item(1)! as Element, 'font-weight'), equals('400'));
    });

    test('a nested at-rule applies', () {
      final host = render([
        css('.box', [
          css('&').styles(width: 10.px),
          css.media(MediaQuery.all(minWidth: 1.px), [css('&').styles(width: 20.px)]),
        ]),
      ], '<div class="box">box</div>');

      // The query matches any viewport, so the nested rule is the one that
      // wins — which only happens if the browser read it as nested css.
      expect(styleOf(host.querySelector('.box')!, 'width'), equals('20px'));
    });

    test('three levels deep still resolve', () {
      final host = render([
        css('.a', [
          css('.b', [
            css('.c').styles(color: Color.rgb(4, 5, 6)),
          ]),
        ]),
      ], '<div class="a"><div class="b"><div class="c">deep</div></div></div>');

      expect(styleOf(host.querySelector('.c')!, 'color'), equals('rgb(4, 5, 6)'));
    });
  });
}
