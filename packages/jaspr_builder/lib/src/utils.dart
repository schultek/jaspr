// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:jaspr/src/foundation/annotations.dart' show AppAnnotation, Import, IslandAnnotation;
import 'package:jaspr/src/framework/framework.dart'  show Component, Key;

import 'package:source_gen/source_gen.dart';

const String generationHeader = "// GENERATED FILE, DO NOT MODIFY\n"
    "// Generated with jaspr_builder\n";

var appChecker = TypeChecker.fromRuntime(AppAnnotation);
var islandChecker = TypeChecker.fromRuntime(IslandAnnotation);
var componentChecker = TypeChecker.fromRuntime(Component);
final keyChecker = TypeChecker.fromRuntime(Key);
var importChecker = TypeChecker.fromRuntime(Import);

class ImportEntry {
  String url;
  List<String> show;
  final int platform;

  ImportEntry(this.url, this.show, this.platform);

  Map<String, dynamic> toJson() {
    return {'url': url, 'show': show, 'platform': platform};
  }
}

extension TypeStub on String {
  bool get isType {
    var n = substring(0, 1);
    return n.toLowerCase() != n;
  }
}

extension ElementNode on Element {
  AstNode? get node {
    var result = session?.getParsedLibraryByElement(library!);
    if (result is ParsedLibraryResult) {
      return result.getElementDeclaration(this)?.node;
    } else {
      return null;
    }
  }
}
