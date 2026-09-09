import 'package:jaspr_cli/src/helpers/port_helper.dart';
import 'package:test/test.dart';

import '../src/fakes/fake_io.dart';

void main() {
  group('port_helper', () {
    late FakeIO io;

    setUp(() {
      io = FakeIO();
    });

    tearDown(() {
      io.tearDown();
    });

    test('isPortAvailable returns true when port is free and false when in use', () async {
      await io.runZoned(() async {
        expect(await isPortAvailable(8080), isTrue);

        io.inUsePorts.add(8080);
        expect(await isPortAvailable(8080), isFalse);
      });
    });

    test('findAvailablePort finds the first available port', () async {
      await io.runZoned(() async {
        expect(await findAvailablePort(8080), equals(8080));

        io.inUsePorts.add(8080);
        expect(await findAvailablePort(8080), equals(8081));

        io.inUsePorts.add(8081);
        expect(await findAvailablePort(8080), equals(8082));
      });
    });

    test('findAvailablePort respects exclude list', () async {
      await io.runZoned(() async {
        expect(await findAvailablePort(8080, exclude: [8080, 8081]), equals(8082));
      });
    });
  });
}
