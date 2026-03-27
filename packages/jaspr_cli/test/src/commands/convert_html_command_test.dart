import 'package:jaspr_cli/src/command_runner.dart';
import 'package:jaspr_cli/src/commands/convert_html_command.dart';
import 'package:test/test.dart';

import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';

void main() {
  group('convert-html command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false);
    });

    test('fails when neither --html, --file nor --url is provided', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        final result = await runner.run(['convert-html']);

        expect(result, equals(1));
        await expectLater(io.stderr.queue, emits(contains('Either --html, --file or --url must be provided.')));
      });
    });

    test('fails when file does not exist', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        final result = await runner.run(['convert-html', '--file', 'nonexistent.html']);

        expect(result, equals(1));
        await expectLater(io.stderr.queue, emits(contains('File not found: nonexistent.html')));
      });
    });

    test('converts html from string', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        final result = await runner.run(['convert-html', '--html', '"<div><p>Hello</p></div>"', '--json']);

        expect(result, equals(0));
        await expectLater(
          io.stdout.queue,
          emits('{"result":"div([\\n  p([\\n    .text(\'Hello\'),\\n  ]),\\n])"}'),
        );
      });
    });

    test('converts html from a file', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        io.fs.file('/root/test.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('<div><p>Hello</p></div>');

        final result = await runner.run(['convert-html', '--file', '/root/test.html', '--json']);

        expect(result, equals(0));
        await expectLater(
          io.stdout.queue,
          emits('{"result":"div([\\n  p([\\n    .text(\'Hello\'),\\n  ]),\\n])"}'),
        );
      });
    });

    test('converts html from a file with query selector', () async {
      await io.runZoned(() async {
        io.stubDartSDK();

        io.fs.file('/root/test.html')
          ..createSync(recursive: true)
          ..writeAsStringSync('<body><header>Header</header><main><p>Content</p></main></body>');

        final result = await runner.run(['convert-html', '--file', '/root/test.html', '--query', 'main', '--json']);

        expect(result, equals(0));
        await expectLater(
          io.stdout.queue,
          emits('{"result":"main_([\\n  p([\\n    .text(\'Content\'),\\n  ]),\\n])"}'),
        );
      });
    });

    group('conversion', () {
      String convert(String html, {String? query}) {
        return ConvertHtmlCommand().convertHtml(html, query);
      }

      test('converts simple element with text', () {
        final result = convert('<div>Hello</div>');
        expect(
          result,
          equals(
            'div([\n'
            '  .text(\'Hello\'),\n'
            '])',
          ),
        );
      });

      test('converts nested elements', () {
        final result = convert('<ul><li>One</li><li>Two</li></ul>');
        expect(
          result,
          equals(
            'ul([\n'
            '  li([\n'
            '    .text(\'One\'),\n'
            '  ]),\n'
            '  li([\n'
            '    .text(\'Two\'),\n'
            '  ]),\n'
            '])',
          ),
        );
      });

      test('converts element with attributes, id and class', () {
        final result = convert('<p id="foo" class="bar" attr="value"></p>');
        expect(result, equals('p(id: \'foo\', classes: \'bar\', attributes: {\'attr\': \'value\'}, [])'));
      });

      test('converts element with multiline text', () {
        final result = convert('<div>Hello\nWorld</div>');
        expect(
          result,
          equals(
            'div([\n'
            '  .text(\'\'\'Hello\n'
            'World\'\'\'),\n'
            '])',
          ),
        );
      });

      test('converts element with special attribute (a href)', () {
        final result = convert('<a href="/foo">Link</a>');
        expect(
          result,
          equals(
            'a(href: \'/foo\', [\n'
            '  .text(\'Link\'),\n'
            '])',
          ),
        );
      });

      test('escapes quotes in text and attributes', () {
        final result = convert('<div title="He said \'Hello\'">She said \'Hi\'</div>');
        expect(
          result,
          equals(
            'div(attributes: {\'title\': \'He said \\\'Hello\\\'\'}, [\n'
            '  .text(\'She said \\\'Hi\\\'\'),\n'
            '])',
          ),
        );
      });

      test('converts content of script and style tags', () {
        final result = convert(
          '<div>Hello<style>.foo { color: red; }</style><script>alert("Hi")</script>World</div>',
        );
        expect(
          result,
          equals(
            'div([\n'
            '  .text(\'Hello\'),\n'
            '  Component.element(tag: \'style\', children: [\n'
            '    .text(\'.foo { color: red; }\')\n'
            '  ]),\n'
            '  script(content: \'alert("Hi")\'),\n'
            '  .text(\'World\'),\n'
            '])',
          ),
        );
      });

      test('converts full document', () {
        final result = convert('<!DOCTYPE html><html><head></head><body>Hello</body></html>');
        expect(result, equals('html([\n  head([]),\n  body([\n    .text(\'Hello\'),\n  ]),\n])'));
      });

      test('converts body', () {
        final result = convert('<body>Hello</body>');
        expect(result, equals('body([\n  .text(\'Hello\'),\n])'));
      });

      test('applies query to converted html', () {
        final result = convert('<div>Hello <p>World</p></div>', query: 'p');
        expect(result, equals('p([\n  .text(\'World\'),\n])'));
      });
    });
  });
}
