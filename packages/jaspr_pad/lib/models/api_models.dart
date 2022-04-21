import 'package:dart_mappable/dart_mappable.dart';

@MappableClass()
class CompileRequest {
  Map<String, String> sources;

  CompileRequest(this.sources);
}

@MappableClass()
class CompileResponse {
  String? result;
  String? error;

  CompileResponse(this.result, this.error);
}

@MappableClass()
class AnalyzeRequest {
  Map<String, String> sources;

  AnalyzeRequest(this.sources);
}

@MappableClass()
class FormatResponse {
  final String newString;

  FormatResponse(this.newString);
}

@MappableClass()
class AnalyzeResponse {
  final List<Issue> issues;

  AnalyzeResponse([this.issues = const []]);
}

@MappableEnum()
enum IssueKind { error, warning, info }

@MappableClass()
class Issue with Comparable<Issue> {
  final IssueKind kind;
  final IssueLocation location;
  final String message;
  final bool hasFixes;
  final String sourceName;
  final String? correction;
  final String? url;

  Issue({
    required this.kind,
    required this.location,
    required this.message,
    required this.hasFixes,
    required this.sourceName,
    this.correction,
    this.url,
  });

  @override
  int compareTo(Issue other) {
    return kind.index.compareTo(other.kind.index);
  }
}

@MappableClass()
class IssueLocation {
  final int startLine, endLine;
  final int startColumn, endColumn;

  IssueLocation({required this.startLine, required this.endLine, required this.startColumn, required this.endColumn});
}
