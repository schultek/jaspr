@TestOn('vm')
library;

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
  testServer('formats $description', (tester) async {
    tester.pumpComponent(input);

    MarkupRenderObject.maxHtmlLineLength = lineLength;
    var response = await tester.request('/');

    expect(response.statusCode, equals(200));
    expect(response.document?.body, isNotNull);

    expect(response.document!.body!.innerHtml.trim(), equals(output));
  });
}

void main() {
  group('markup formatting test', () {
    testOutput(
      'short content',
      input: div([
        span([text('A')]),
        span([text('B')]),
        span([text('C')]),
      ]),
      output: '<div><span>A</span><span>B</span><span>C</span></div>',
      lineLength: 50,
    );

    testOutput(
      'block content',
      input: div([
        span([text('Hello')]),
        span([text('World')]),
        span([text('Test')]),
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
      'paragraph content',
      input: p([
        span([text('Hello ')]),
        span([text('World')]),
        span([text(' Lorem')]),
        span([text('Ipsum')]),
      ]),
      output:
          '<p>\n'
          '      <span>Hello </span><span>World</span>\n'
          '      <span> Lorem</span><span>Ipsum</span>\n'
          '    </p>',
      lineLength: 30,
    );

    testOutput(
      'text content',
      input: p([
        text('Hello '),
        b([text('World')]),
        text('!'),
      ]),
      output:
          '<p>\n'
          '      Hello <b>World</b>!\n'
          '    </p>',
      lineLength: 10,
    );

    testOutput(
      'nested paragraph content',
      input: p([
        span([text('Lorem ')]),
        em([
          text('Hello '),
          b([text('World')]),
        ]),
        span([text(' Ipsum')]),
      ]),
      output:
          '<p>\n'
          '      <span>Lorem </span><em>Hello <b>World</b></em>\n'
          '      <span> Ipsum</span>\n'
          '    </p>',
      lineLength: 20,
    );

    testOutput(
      'formatted text',
      input: p([text('A\nB\nC')]),
      output:
          '<p>\n'
          '      A\n'
          '      B\n'
          '      C\n'
          '    </p>',
      lineLength: 30,
    );

    testOutput(
      'unformatted text',
      input: div([
        span([text('A\nB\nC')]),
        b([text('D')]),
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
      'with fragments',
      input: div([
        fragment([
          p([text('Hello ')]),
          fragment([]),
          fragment([
            p([text('World ')]),
            p([
              fragment([text('Test ')]),
            ]),
          ]),
        ]),
        div([
          fragment([
            fragment([
              p([text('Lorem ')]),
              p([text('Ipsum ')]),
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
      'with preformatted html',
      input: div([
        text('\n   '),
        p([text('\n      '), text('Hello'), text('\n   ')]),
        text('\n'),
      ]),
      output:
          '<div>\n'
          '   <p>\n'
          '      Hello\n'
          '   </p>\n'
          '</div>',
      lineLength: 30,
    );
  });
}
