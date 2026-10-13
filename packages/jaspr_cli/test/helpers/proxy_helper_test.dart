import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jaspr_cli/src/commands/base_command.dart';
import 'package:jaspr_cli/src/dev/dev_proxy.dart';
import 'package:jaspr_cli/src/helpers/proxy_helper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

class MockDevProxy extends Mock implements DevProxy {}

class TestCommand extends BaseCommand with ProxyHelper {
  @override
  String get name => 'test';

  @override
  String get description => 'Test command';

  @override
  Future<int> runCommand() async => 0;
}

void main() {
  group('ProxyHelper redirectNotFound', () {
    late HttpServer server;
    late http.Client client;

    setUp(() async {
      client = http.Client();
      final mockDevProxy = MockDevProxy();

      when(() => mockDevProxy.client).thenReturn(client);
      when(() => mockDevProxy.handler).thenReturn((req) async {
        if (req.url.path.isEmpty) {
          return Response.ok('root page');
        }
        return Response.notFound('Not found');
      });

      final command = TestCommand();
      server = await command.startProxy(
        '0',
        devProxy: mockDevProxy,
        serverPort: '0',
        redirectNotFound: true,
      );
    });

    tearDown(() async {
      await server.close(force: true);
      client.close();
    });

    test('redirects valid routes containing "dwds" to root', () async {
      final res = await client.get(Uri.parse('http://localhost:${server.port}/guides/dwds'));
      expect(res.statusCode, equals(200));
      expect(res.body, equals('root page'));

      final res2 = await client.get(Uri.parse('http://localhost:${server.port}/dwds'));
      expect(res2.statusCode, equals(200));
      expect(res2.body, equals('root page'));
    });

    test('redirects valid route /null to root', () async {
      final res = await client.get(Uri.parse('http://localhost:${server.port}/null'));
      expect(res.statusCode, equals(200));
      expect(res.body, equals('root page'));
    });

    test('does not redirect concrete DWDS endpoint prefixes', () async {
      final res = await client.get(Uri.parse('http://localhost:${server.port}/\$dwdsSseHandler'));
      expect(res.statusCode, equals(404));

      final res2 = await client.get(Uri.parse('http://localhost:${server.port}/\$dwdsExtensionAuthentication'));
      expect(res2.statusCode, equals(404));
    });

    test('does not redirect concrete internal endpoint prefixes', () async {
      final res = await client.get(Uri.parse('http://localhost:${server.port}/\$jasprInternal'));
      expect(res.statusCode, equals(404));
    });
  });
}
