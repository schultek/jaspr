@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:meta/meta.dart';

@isTest
void testOutput(
  String description, {
  required Component input,
  required String output,
  required int lineLength,
}) {
  testServer(description, (tester) async {
    tester.pumpComponent(input);

    MarkupRenderObject.maxHtmlLineLength = lineLength;
    final response = await tester.request('/');

    expect(response.statusCode, equals(200));
    expect(response.document?.body, isNotNull);

    expect(response.document!.body!.innerHtml.trim(), equals(output));
  });
}

void main() {
  group('markup formatting test', () {
    testOutput(
      'formats short content',
      input: div([
        span([Component.text('A')]),
        span([Component.text('B')]),
        span([Component.text('C')]),
      ]),
      output: '<div><span>A</span><span>B</span><span>C</span></div>',
      lineLength: 50,
    );

    testOutput(
      'formats block content',
      input: div([
        span([Component.text('Hello')]),
        span([Component.text('World')]),
        span([Component.text('Test')]),
      ]),
      output:
          '<div>\n'
          '      <span>Hello</span>\n'
          '      <span>World</span>\n'
          '      <span>Test</span>\n'
          '    </div>',
      lineLength: 50,
    );

    testOutput(
      'formats paragraph content',
      input: p([
        span([Component.text('Hello ')]),
        span([Component.text('World')]),
        span([Component.text(' Lorem')]),
        span([Component.text('Ipsum')]),
      ]),
      output:
          '<p>\n'
          '      <span>Hello </span><span>World</span>\n'
          '      <span> Lorem</span><span>Ipsum</span>\n'
          '    </p>',
      lineLength: 30,
    );

    testOutput(
      'formats text content',
      input: p([
        Component.text('Hello '),
        b([Component.text('World')]),
        Component.text('!'),
      ]),
      output:
          '<p>\n'
          '      Hello <b>World</b>!\n'
          '    </p>',
      lineLength: 10,
    );

    testOutput(
      'formats nested paragraph content',
      input: p([
        span([Component.text('Lorem ')]),
        em([
          Component.text('Hello '),
          b([Component.text('World')]),
        ]),
        span([Component.text(' Ipsum')]),
      ]),
      output:
          '<p>\n'
          '      <span>Lorem </span><em>Hello <b>World</b></em>\n'
          '      <span> Ipsum</span>\n'
          '    </p>',
      lineLength: 20,
    );

    testOutput(
      'formats formatted text',
      input: p([Component.text('A\nB\nC')]),
      output:
          '<p>\n'
          '      A\n'
          '      B\n'
          '      C\n'
          '    </p>',
      lineLength: 30,
    );

    testOutput(
      'formats unformatted text',
      input: div([
        span([Component.text('A\nB\nC')]),
        b([Component.text('D')]),
      ]),
      output:
          '<div>\n'
          '      <span>A\n'
          'B\n'
          'C</span>\n'
          '      <b>D</b>\n'
          '    </div>',
      lineLength: 30,
    );

    testOutput(
      'formats content with fragments',
      input: div([
        Component.fragment([
          p([Component.text('Hello ')]),
          Component.fragment([]),
          Component.fragment([
            p([Component.text('World ')]),
            p([
              Component.fragment([Component.text('Test ')]),
            ]),
          ]),
        ]),
        div([
          Component.fragment([
            Component.fragment([
              p([Component.text('Lorem ')]),
              p([Component.text('Ipsum ')]),
            ]),
          ]),
        ]),
      ]),
      output:
          '<div>\n'
          '      <p>Hello </p>\n'
          '      <p>World </p>\n'
          '      <p>Test </p>\n'
          '      <div>\n'
          '        <p>Lorem </p>\n'
          '        <p>Ipsum </p>\n'
          '      </div>\n'
          '    </div>',
      lineLength: 20,
    );

    testOutput(
      'formats content with preformatted html',
      input: div([
        Component.text('\n   '),
        p([Component.text('\n      '), Component.text('Hello'), Component.text('\n   ')]),
        Component.text('\n'),
      ]),
      output:
          '<div>\n'
          '   <p>\n'
          '      Hello\n'
          '   </p>\n'
          '</div>',
      lineLength: 30,
    );

    testOutput(
      'formats empty content',
      input: div([
        span([Component.text('')]),
        Component.text('Hello'),
        b([]),
        Component.text(''),
        Component.fragment([Component.text('')]),
        Component.fragment([]),
      ]),
      output: '<div><span></span>Hello<b></b></div>',
      lineLength: 30,
    );
  });
}
