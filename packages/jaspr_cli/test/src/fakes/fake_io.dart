import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:async/async.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:jaspr_cli/src/process_runner.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_socket.dart';

class FakeIO {
  FakeIO()
    : fs = MemoryFileSystem(),
      process = MockProcessRunner(),
      sockets = MockSockets(),
      stdin = FakeStdin(),
      stdout = FakeIOSink(),
      stderr = FakeIOSink() {
    fs.directory('/root').createSync();
    fs.currentDirectory = io.Directory('/root');

    throwOnMissingStub(process);
  }

  late final MemoryFileSystem fs;
  final MockProcessRunner process;
  final MockSockets sockets;

  final _serverSocketsController = StreamController<FakeServerSocket>();
  late final StreamQueue<FakeServerSocket> serverSockets = StreamQueue(_serverSocketsController.stream);

  final FakeStdin stdin;
  final FakeIOSink stdout;
  final FakeIOSink stderr;

  int? _exitCode;
  int? get exitCode => _exitCode;

  T runZoned<T>(T Function() body) {
    return io.IOOverrides.runZoned(
      () => ProcessRunner.runZoned(body, process),
      getCurrentDirectory: () => fs.currentDirectory,
      setCurrentDirectory: (path) => fs.currentDirectory = path,
      createFile: fs.file,
      createDirectory: fs.directory,
      createLink: fs.link,
      fseGetType: (p, followLinks) => fs.type(p, followLinks: followLinks),
      fseGetTypeSync: (p, followLinks) => fs.typeSync(p, followLinks: followLinks),
      stat: fs.stat,
      statSync: fs.statSync,
      fseIdentical: fs.identical,
      fseIdenticalSync: fs.identicalSync,
      fsWatchIsSupported: () => fs.isWatchSupported,
      socketConnect: (host, port, {sourceAddress, sourcePort = 0, timeout}) => sockets.connect(host, port),
      socketStartConnect: (host, port, {sourceAddress, sourcePort = 0, timeout}) async =>
          io.ConnectionTask.fromSocket(sockets.connect(host, port), () {}),
      serverSocketBind: (host, port, {backlog = 0, shared = false, v6Only = false}) async {
        final socket = FakeServerSocket(await _lookupAddress(host), port, this);
        _serverSocketsController.add(socket);
        return socket;
      },
      stdin: () => stdin,
      stdout: () => FakeStdout(stdout.sink),
      stderr: () => FakeStdout(stderr.sink),
      // ignore: sdk_version_since
      exit: (e) {
        _exitCode = e;
        throw Exception('Exit called.');
      },
    );
  }

  Future<io.InternetAddress> _lookupAddress(dynamic host) async {
    return host is io.InternetAddress ? host : (await io.InternetAddress.lookup(host.toString())).first;
  }

  Future<void> tearDown() async {
    _serverSocketsController.close();
  }
}

class MockSockets extends Mock {
  Future<io.Socket> connect(dynamic host, int port) {
    return super.noSuchMethod(Invocation.method(#connect, [host, port])) as Future<io.Socket>;
  }
}

class FakeProcess extends Mock implements io.Process {
  FakeProcess();

  FakeProcess.sync({int exitCode = 0, String stdout = '', String stderr = ''}) {
    _exitCode.complete(exitCode);
    _stdout.add(stdout);
    _stderr.add(stderr);
  }

  final Completer<int> _exitCode = Completer<int>();
  final _stdout = StreamController<String>();
  final _stderr = StreamController<String>();

  void writeStdout(String s) => _stdout.add('$s\n');
  void writeStderr(String s) => _stderr.add('$s\n');

  void exit(int code) {
    _exitCode.complete(code);
  }

  @override
  Future<int> get exitCode => _exitCode.future;

  @override
  Stream<List<int>> get stdout => _stdout.stream.transform(utf8.encoder);

  @override
  Stream<List<int>> get stderr => _stderr.stream.transform(utf8.encoder);

  // Implement other members as needed or let Mock handle them (throwing/returning null)
  // For basic create/serve/build we mostly need exitCode, stdout, stderr and maybe stdin.
  @override
  IOSink get stdin => IOSink(StreamController<List<int>>().sink);

  @override
  bool kill([io.ProcessSignal signal = io.ProcessSignal.sigterm]) {
    if (!_exitCode.isCompleted) _exitCode.complete(1);
    return true;
  }
}

class MockProcessRunner extends Mock implements ProcessRunner {}

class FakeStdout implements io.Stdout {
  FakeStdout(this.sink);

  final IOSink sink;

  @override
  bool get hasTerminal => false;

  @override
  io.IOSink get nonBlocking => sink;

  @override
  bool get supportsAnsiEscapes => false;

  @override
  int get terminalColumns => throw io.StdoutException('terminalColumns not supported');

  @override
  int get terminalLines => throw io.StdoutException('terminalLines not supported');

  @override
  Encoding get encoding => sink.encoding;
  @override
  set encoding(Encoding encoding) => sink.encoding = encoding;

  @override
  String get lineTerminator => io.stdout.lineTerminator;
  @override
  set lineTerminator(String lineTerminator) => io.stdout.lineTerminator = lineTerminator;

  @override
  void add(List<int> data) => sink.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) => sink.addError(error, stackTrace);

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) => sink.addStream(stream);

  @override
  Future<dynamic> close() => sink.close();

  @override
  Future<dynamic> get done => sink.done;

  @override
  Future<dynamic> flush() => sink.flush();

  @override
  void write(Object? object) => sink.write(object);

  @override
  void writeAll(Iterable<dynamic> objects, [String sep = '']) => sink.writeAll(objects, sep);

  @override
  void writeCharCode(int charCode) => sink.writeCharCode(charCode);

  @override
  void writeln([Object? object = '']) => sink.writeln(object);
}

class FakeIOSink implements StreamConsumer<List<int>> {
  FakeIOSink();

  late final StreamQueue<String> queue = StreamQueue<String>(
    _controller.stream.transform(utf8.decoder).transform(LineSplitter()),
  );

  final _controller = StreamController<List<int>>();

  Stream<List<int>> get reverse => _controller.stream;

  @override
  Future<dynamic> addStream(Stream<List<int>> stream) {
    return _controller.addStream(stream);
  }

  @override
  Future<dynamic> close() {
    return _controller.close();
  }

  late final io.IOSink sink = IOSink(this);
}

class FakeStdin extends Stream<List<int>> implements io.Stdin {
  final List<String> _lines = [];
  final StreamController<List<int>> _controller = StreamController<List<int>>();

  void addLine(String line) {
    _lines.add(line);
    _controller.add(utf8.encode(line));
  }

  @override
  bool echoMode = true;

  @override
  bool echoNewlineMode = false;

  @override
  bool lineMode = true;

  @override
  bool get hasTerminal => false;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  @override
  int readByteSync() {
    if (_lines.isEmpty) {
      throw io.StdinException('No more lines to read');
    }
    final line = _lines[0];
    if (line.isEmpty) {
      _lines.removeAt(0);
      return '\n'.codeUnitAt(0);
    }
    _lines[0] = line.substring(1);
    return line.codeUnitAt(0);
  }

  @override
  String? readLineSync({Encoding encoding = io.systemEncoding, bool retainNewlines = false}) {
    if (_lines.isEmpty) {
      throw io.StdinException('No more lines to read');
    }
    final line = _lines.removeAt(0);
    return line;
  }

  @override
  bool get supportsAnsiEscapes => false;
}
