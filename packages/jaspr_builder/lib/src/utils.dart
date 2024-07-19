// ignore_for_file: implementation_imports

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:jaspr/jaspr.dart' show ClientAnnotation, CssUtility, Import, Component, Key, StyleRule;
import 'package:source_gen/source_gen.dart';

const String generationHeader = "// GENERATED FILE, DO NOT MODIFY\n"
    "// Generated with jaspr_builder\n";

var clientChecker = TypeChecker.fromRuntime(ClientAnnotation);
var stylesChecker = TypeChecker.fromRuntime(CssUtility);
var styleRuleChecker = TypeChecker.fromRuntime(StyleRule);
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
