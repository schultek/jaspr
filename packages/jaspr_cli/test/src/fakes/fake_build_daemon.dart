import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:build_daemon/constants.dart';
import 'package:build_daemon/data/build_request.dart';
import 'package:build_daemon/data/build_status.dart';
import 'package:build_daemon/data/build_target_request.dart';
import 'package:build_daemon/data/serializers.dart';
import 'package:build_daemon/data/shutdown_notification.dart';
import 'package:jaspr_cli/src/dev/util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'fake_io.dart';
import 'fake_socket.dart';

extension FakeBuildDaemonIO on FakeIO {
  FakeBuildDaemon setupFakeBuildDaemon({List<String>? verifyArgs}) {
    when(
      () => process.start(
        '/fake/bin/dart',
        any(that: containsAllInOrder(['run', 'build_runner', 'daemon'])),
        workingDirectory: '/root/myapp',
      ),
    ).thenAnswer((inv) async {
      if (verifyArgs != null) {
        final args = (inv.positionalArguments[1] as List).sublist(3);
        expect(args, equals(verifyArgs));
      }

      fs.file(portFilePath('/root/myapp'))
        ..createSync(recursive: true)
        ..writeAsStringSync('1234');
      fs.file(assetServerPortFilePath('/root/myapp'))
        ..createSync(recursive: true)
        ..writeAsStringSync('1235');
      return FakeProcess.sync(exitCode: 0, stdout: '', stderr: '');
    });

    final socket = FakeSocket(InternetAddress.anyIPv4, 1234);
    when(() => sockets.connect('localhost', 1234)).thenAnswer((_) async => socket);

    return FakeBuildDaemon(
      Future(() async {
        final webSocket = await upgradeToReverseWebSocket(socket);
        return webSocket;
      }),
    );
  }

  Future<void> runInitialBuild(FakeBuildDaemon buildDaemon) async {
    await expectLater(
      buildDaemon.messages,
      emitsInOrder([
        isA<BuildTargetRequest>(),
        isA<BuildRequest>(),
      ]),
    );

    buildDaemon.sendMessage(
      BuildResults((b) {
        b.results.add(
          DefaultBuildResult((b) {
            b.target = 'web';
            b.status = BuildStatus.succeeded;
          }),
        );
      }),
    );
  }

  Future<void> runReleaseBuild(FakeBuildDaemon buildDaemon) async {
    expect(
      this.stdout.queue,
      emitsInOrder([
        'Building web assets...',
        '[BUILDER] Connecting to the build daemon...',
      ]),
    );

    await expectLater(
      buildDaemon.messages,
      emitsInOrder([
        isA<BuildTargetRequest>(),
        isA<BuildRequest>(),
      ]),
    );

    buildDaemon.sendMessage(
      BuildResults((b) {
        b.results.add(
          DefaultBuildResult((b) {
            b.target = 'web';
            b.status = BuildStatus.started;
          }),
        );
      }),
    );

    buildDaemon.sendMessage(
      BuildResults((b) {
        b.results.add(
          DefaultBuildResult((b) {
            b.target = 'web';
            b.status = BuildStatus.succeeded;
          }),
        );
      }),
    );

    await expectLater(
      this.stdout.queue,
      emitsInOrder([
        'Completed building web assets.',
      ]),
    );
  }

  Future<void> shutdownBuildDaemon(FakeBuildDaemon buildDaemon) async {
    buildDaemon.sendMessage(
      ShutdownNotification((b) {
        b.failureType = 0;
        b.message = 'Shutting down fake build daemon.';
      }),
    );
    await buildDaemon.close();

    await expectLater(this.stderr.queue, emits('[BUILDER] [WARNING] Shutting down fake build daemon.'));
  }
}

class FakeBuildDaemon {
  FakeBuildDaemon(Future<WebSocket> webSocket) {
    webSocket.then((ws) {
      _webSocket = ws;
    });
    messages = StreamQueue(
      Stream.fromFuture(webSocket).asyncExpand((ws) {
        return ws.map((data) => serializers.deserialize(jsonDecode(data as String)));
      }),
    );
  }

  WebSocket? _webSocket;
  late final StreamQueue<Object?> messages;

  void sendMessage(Object message) {
    expect(_webSocket, isNotNull, reason: 'Cannot send message before build daemon is connected.');
    _webSocket!.add(jsonEncode(serializers.serialize(message)));
  }

  Future<void> close() async {
    await _webSocket?.close();
  }
}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}
