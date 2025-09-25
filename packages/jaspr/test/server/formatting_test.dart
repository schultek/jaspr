@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/server_test.dart';
import 'package:meta/meta.dart';

final _ = ''.padLeft(40, '-');

@isTest
void testOutput(String description, {required Component input, required String output}) {
  testServer('formats $description', (tester) async {
    tester.pumpComponent(input);

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
    );

    testOutput(
      'block content',
      input: div([
        span([text('A $_')]),
        span([text('B $_')]),
        span([text('C $_')]),
      ]),
      output:
          '<div>\n'
          '      <span>A $_</span>\n'
          '      <span>B $_</span>\n'
          '      <span>C $_</span>\n'
          '    </div>',
    );

    testOutput(
      'paragraph content',
      input: p([
        span([text('A $_ ')]),
        span([text('B $_')]),
        span([text(' C $_')]),
        span([text('D')]),
      ]),
      output:
          '<p>\n'
          '      <span>A $_ </span>\n'
          '      <span>B $_</span>\n'
          '      <span> C $_</span><span>D</span>\n'
          '    </p>',
    );

    testOutput(
      'text content',
      input: p([
        text('Hello $_ '),
        b([text('World $_')]),
        text('C $_'),
      ]),
      output:
          '<p>\n'
          '      Hello $_ \n'
          '      <b>World $_</b>C $_\n'
          '    </p>',
    );

    testOutput(
      'nested paragraph content',
      input: p([
        span([text('A $_')]),
        em([
          text('Hello $_ '),
          b([text('World $_')]),
        ]),
        span([text('C $_')]),
      ]),
      output:
          '<p>\n'
          '      <span>A $_</span><em>Hello $_ \n'
          '        <b>World $_</b></em><span>C $_</span>\n'
          '    </p>',
    );

    testOutput(
      'formatted text',
      input: p([text('A $_\nB $_\nC')]),
      output:
          '<p>\n'
          '      A $_\n'
          '      B $_\n'
          '      C\n'
          '    </p>',
    );

    testOutput(
      'unformatted text',
      input: div([
        span([text('A $_\nB $_\nC')]),
        b([text('D $_')]),
      ]),
      output:
          '<div>\n'
          '      <span>A $_\n'
          'B $_\n'
          'C</span>\n'
          '      <b>D $_</b>\n'
          '    </div>',
    );

    testOutput(
      'with fragments',
      input: div([
        fragment([
          p([text('A $_ ')]),
          fragment([]),
          fragment([
            p([text('B $_ ')]),
            p([
              fragment([text('C $_ ')]),
            ]),
          ]),
        ]),
        div([
          fragment([
            fragment([
              p([text('D $_ ')]),
              p([text('E $_ ')]),
            ]),
          ]),
        ]),
      ]),
      output:
          '<div>\n'
          '      <p>A ---------------------------------------- </p>\n'
          '      <p>B ---------------------------------------- </p>\n'
          '      <p>C ---------------------------------------- </p>\n'
          '      <div>\n'
          '        <p>D ---------------------------------------- </p>\n'
          '        <p>E ---------------------------------------- </p>\n'
          '      </div>\n'
          '    </div>',
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
    );
  });
}
