import 'package:dart_mappable/dart_mappable.dart';

part 'api_models.mapper.dart';

@MappableClass()
class CompileRequest with CompileRequestMappable {
  Map<String, String> sources;

  CompileRequest(this.sources);
}

@MappableClass()
class CompileResponse with CompileResponseMappable {
  String? result;
  String? error;

  CompileResponse(this.result, this.error);
}

@MappableClass()
class AnalyzeRequest with AnalyzeRequestMappable {
  Map<String, String> sources;

  AnalyzeRequest(this.sources);
}

@MappableClass()
class FormatResponse with FormatResponseMappable {
  final String newString;
  final int newOffset;

  FormatResponse(this.newString, this.newOffset);
}

@MappableClass()
class FormatRequest with FormatRequestMappable {
  final String source;
  final int offset;

  FormatRequest(this.source, this.offset);
}

@MappableClass()
class AnalyzeResponse with AnalyzeResponseMappable {
  final List<Issue> issues;

  AnalyzeResponse([this.issues = const []]);
}

@MappableEnum()
enum IssueKind { error, warning, info }

@MappableClass()
class Issue with IssueMappable implements Comparable<Issue> {
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
class IssueLocation with IssueLocationMappable {
  final int startLine, endLine;
  final int startColumn, endColumn;

  IssueLocation({required this.startLine, required this.endLine, required this.startColumn, required this.endColumn});
}

@MappableClass()
class DocumentResponse with DocumentResponseMappable {
  final HoverInfo info;
  final String? error;

  DocumentResponse(this.info, this.error);
}

@MappableClass()
class HoverInfo with HoverInfoMappable {
  final String? description;
  final String? kind;
  final String? dartdoc;
  final String? enclosingClassName;
  final String? libraryName;
  final String? parameter;
  final bool? deprecated;
  final String? staticType;
  final String? propagatedType;

  HoverInfo(
      {this.description,
      this.kind,
      this.dartdoc,
      this.enclosingClassName,
      this.libraryName,
      this.parameter,
      this.deprecated,
      this.staticType,
      this.propagatedType});
}

@MappableClass()
class DocumentRequest with DocumentRequestMappable {
  final Map<String, String> sources;
  final String name;
  final int offset;

  DocumentRequest(this.sources, this.name, this.offset);
}
