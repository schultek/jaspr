import 'package:jaspr_cli/src/command_runner.dart';
import 'package:test/test.dart';

import '../fakes/fake_build_daemon.dart';
import '../fakes/fake_io.dart';
import '../fakes/fake_project.dart';
import '../fakes/fake_socket.dart';

void main() {
  group('daemon command', () {
    late JasprCommandRunner runner;
    late FakeIO io;

    setUp(() {
      io = FakeIO();
      runner = JasprCommandRunner(false);
    });

    tearDown(() {
      io.tearDown();
    });

    test('runs daemon with client mode', () async {
      await io.runZoned(() async {
        io.setupFakeProject('myapp', mode: 'client');
        io.stubDartSDK();

        final buildDaemon = io.setupFakeBuildDaemon();

        final serveResult = runner.run(['daemon', '--no-launch-in-chrome']);

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            startsWith('[{"event":"daemon.connected","params":{"version":"0.4.2","pid":'),
            '[{"event":"daemon.log","params":{"message":"Running jaspr in client rendering mode."}}]',
            r'[{"event":"daemon.log","params":{"message":"\\033[36m[CLI] \\033[0mStarting web compilers..."}}]',
            r'[{"event":"daemon.log","params":{"message":"\\033[35m[BUILDER] \\033[0mConnecting to the build daemon..."}}]',
            r'[{"event":"daemon.log","params":{"message":"\\033[35m[BUILDER] \\033[0mStarting initial build..."}}]',
          ]),
        );

        await io.runInitialBuild(buildDaemon);

        await expectLater(
          io.serverSockets.next,
          completion(isA<FakeServerSocket>().having((s) => s.port, 'port', 8080)),
        );

        await expectLater(
          io.stdout.queue,
          emitsInOrder([
            r'[{"event":"daemon.log","params":{"message":"\\033[36m[CLI] \\033[0mDone building web assets."}}]',
            r'[{"event":"daemon.log","params":{"message":"\\033[36m[CLI] \\033[0mServing at http://localhost:8080"}}]',
          ]),
        );

        io.stdin.addLine('[{"method":"daemon.shutdown","id":0}]');

        expect(
          io.stdout.queue,
          emitsInOrder([
            '[{"id":0}]',
            '[{"event":"daemon.log","params":{"message":"Terminating web compilers..."}}]',
          ]),
        );

        expect(await serveResult, equals(0));
      });
    });
  });
}
