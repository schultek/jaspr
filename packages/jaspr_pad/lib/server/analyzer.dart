import 'dart:async';
import 'dart:io';

import 'package:analysis_server_lib/analysis_server_lib.dart';
import 'package:path/path.dart' as path;

import '../main.mapper.g.dart';
import '../models/api_models.dart';
import 'project.dart';
import 'scheduler.dart';

// Use very long timeouts to ensure that the server has enough time to restart.
const Duration _analysisServerTimeout = Duration(seconds: 35);
const Duration _analysisWarmupTimeout = Duration(seconds: 60);

const String _warmupSrc = 'main() { int b = 2;  b++;   b. }';
final mainPath = path.join(jasprBasicTemplatePath, 'main.dart');

class Analyzer {
  final TaskScheduler serverScheduler = TaskScheduler();

  /// Instance to handle communication with the server.
  late AnalysisServer analysisServer;

  Analyzer() {
    init();
  }

  Future<void> init() async {
    serverScheduler.schedule(ClosureTask(() async {
      var sdkPath = Platform.environment['DART_SDK_PATH'];
      analysisServer = await AnalysisServer.create(sdkPath: sdkPath, clientId: 'JasprPad');

      analysisServer.server.onError.listen((ServerError error) {
        print('server error${error.isFatal ? ' (fatal)' : ''}: ${error.message}');
      });
      await analysisServer.server.onConnected.first;
      await analysisServer.server.setSubscriptions(<String>['STATUS']);

      await analysisServer.analysis.setAnalysisRoots([jasprBasicTemplatePath], []);

      // Warmup.
      await _sendAddOverlays({mainPath: _warmupSrc});
      await _sendRemoveOverlays();
    }, timeoutDuration: _analysisWarmupTimeout));
  }

  Future<AnalyzeResponse> analyze(AnalyzeRequest request) {
    return serverScheduler.schedule(ClosureTask<AnalyzeResponse>(() async {
      var sources = request.sources.map((k, v) => MapEntry(path.join(jasprBasicTemplatePath, k), v));

      await _loadSources(sources);
      final errors = (await analysisServer.analysis.getErrors(mainPath)).errors;
      await _unloadSources();

      var lines = request.sources.map((k, v) => MapEntry(k, Lines(v)));

      return AnalyzeResponse(errors.map((error) {
        var name = path.basename(error.location.file);
        var line = lines[name]!;

        final endLine = line.getLineForOffset(error.location.offset + error.location.length);
        final offsetForEndLine = line.offsetForLine(endLine);
        var endColumn = error.location.offset + error.location.length - offsetForEndLine;

        return Issue(
          kind: Mapper.fromValue(error.severity.toLowerCase()),
          location: IssueLocation(
            startLine: error.location.startLine - 1,
            startColumn: error.location.startColumn - 1,
            endLine: endLine,
            endColumn: endColumn,
          ),
          message: error.message,
          sourceName: name,
          hasFixes: error.hasFix ?? false,
          url: error.url,
          correction: error.correction,
        );
      }).toList());
    }, timeoutDuration: _analysisServerTimeout));
  }

  Future<FormatResponse> format(FormatRequest request) async {
    return serverScheduler.schedule(ClosureTask<FormatResponse>(() async {
      await _loadSources({mainPath: request.source});
      final FormatResult result;
      try {
        result = await analysisServer.edit.format(mainPath, request.offset, 0);
      } finally {
        await _unloadSources();
      }

      final edits = result.edits;
      edits.sort((SourceEdit e1, SourceEdit e2) => -1 * e1.offset.compareTo(e2.offset));

      var src = request.source;
      for (final edit in edits) {
        src = src.replaceRange(edit.offset, edit.offset + edit.length, edit.replacement);
      }

      return FormatResponse(src, result.selectionOffset);
    }, timeoutDuration: _analysisServerTimeout));
  }

  Future<DocumentResponse> document(DocumentRequest request) async {
    return serverScheduler.schedule(ClosureTask<DocumentResponse>(() async {
      var sources = request.sources.map((k, v) => MapEntry(path.join(jasprBasicTemplatePath, k), v));
      await _loadSources(sources);

      final result =
          await analysisServer.analysis.getHover(path.join(jasprBasicTemplatePath, request.name), request.offset);
      await _unloadSources();

      if (result.hovers.isEmpty) {
        return DocumentResponse(HoverInfo(), null);
      }

      final info = result.hovers.first;

      return DocumentResponse(
        HoverInfo(
          description: info.elementDescription,
          kind: info.elementKind,
          dartdoc: info.dartdoc,
          enclosingClassName: info.containingClassDescription,
          libraryName: info.containingLibraryName,
          parameter: info.parameter,
          deprecated: info.isDeprecated,
          staticType: info.staticType,
          propagatedType: info.propagatedType,
        ),
        null,
      );
    }, timeoutDuration: _analysisServerTimeout));
  }

  final Set<String> _overlayPaths = <String>{};

  /// Loads [sources] as file system overlays to the analysis server.
  ///
  /// The analysis server then begins to analyze these as priority files.
  Future<void> _loadSources(Map<String, String> sources) async {
    if (_overlayPaths.isNotEmpty) {
      throw StateError('There should be no overlay paths while loading sources, but we '
          'have: $_overlayPaths');
    }
    await _sendAddOverlays(sources);
    await analysisServer.analysis.setPriorityFiles(sources.keys.toList());
  }

  Future<void> _unloadSources() async {
    await _sendRemoveOverlays();
    await analysisServer.analysis.setPriorityFiles([]);
  }

  /// Sends [overlays] to the analysis server.
  Future<void> _sendAddOverlays(Map<String, String> overlays) async {
    final contentOverlays = overlays.map((overlayPath, content) => MapEntry(overlayPath, AddContentOverlay(content)));

    _overlayPaths.addAll(contentOverlays.keys);

    await analysisServer.analysis.updateContent(contentOverlays);
  }

  Future<void> _sendRemoveOverlays() async {
    final contentOverlays = {for (final overlayPath in _overlayPaths) overlayPath: RemoveContentOverlay()};
    _overlayPaths.clear();

    await analysisServer.analysis.updateContent(contentOverlays);
  }
}

class Lines {
  final _starts = <int>[];

  Lines(String source) {
    final units = source.codeUnits;
    var nextIsEol = true;
    for (var i = 0; i < units.length; i++) {
      if (nextIsEol) {
        nextIsEol = false;
        _starts.add(i);
      }
      if (units[i] == 10) nextIsEol = true;
    }
  }

  /// Return the 0-based line number.
  int getLineForOffset(int offset) {
    if (_starts.isEmpty) return 0;
    for (var i = 1; i < _starts.length; i++) {
      if (offset < _starts[i]) return i - 1;
    }
    return _starts.length - 1;
  }

  int offsetForLine(int line) {
    assert(line >= 0);
    if (_starts.isEmpty) return 0;
    if (line >= _starts.length) line = _starts.length - 1;
    return _starts[line];
  }
}
