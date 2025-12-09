// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

export 'package:analysis_server_plugin/edit/dart/dart_fix_kind_priority.dart';
export 'package:analyzer/error/error.dart';
export 'package:analyzer_plugin/utilities/assist/assist.dart';
export 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
export 'package:analyzer_plugin/utilities/change_builder/change_builder_dart.dart';
export 'package:analyzer_plugin/utilities/fixes/fixes.dart';
export 'package:analyzer_plugin/utilities/range_factory.dart';

bool isComponentType(DartType? type) {
  return type != null && type.accept(IsComponentVisitor());
}

bool isStylesType(DartType? type) {
  if (type == null || type is! InterfaceType) return false;
  final name = type.element.name;
  final lib = type.element.library;

  return lib.identifier == 'package:jaspr/src/dom/styles/styles.dart' && name == 'Styles';
}

bool isComponentListType(DartType? type) {
  return type != null &&
      type.isDartCoreList &&
      (type as InterfaceType).typeArguments.first.accept(IsComponentVisitor());
}

int getLineIndent(LineInfo lineInfo, AstNode node) {
  final lineNumber = lineInfo.getLocation(node.offset).lineNumber - 1;
  final lineOffset = lineInfo.getOffsetOfLine(lineNumber);
  Token token = node.beginToken;
  while (token.previous != null && token.previous!.offset >= lineOffset) {
    token = token.previous!;
  }
  return token.offset - lineOffset;
}

bool hasClassesParameter(List<FormalParameterElement>? params) {
  if (params == null) return false;
  return params.where((p) => p.isNamed && p.name == 'classes' && p.type.isDartCoreString).isNotEmpty;
}

(ClassDeclaration, MethodDeclaration)? findParentComponent(AstNode? node) {
  if (node == null) {
    return null;
  } else if (node is MethodDeclaration) {
    if (node.name.lexeme == 'build' && node.parent is ClassDeclaration) {
      return (node.parent as ClassDeclaration, node);
    } else {
      return null;
    }
  } else {
    return findParentComponent(node.parent);
  }
}

class IsComponentVisitor extends UnifyingTypeVisitor<bool> {
  @override
  bool visitDartType(DartType type) {
    return false;
  }

  @override
  bool visitInterfaceType(InterfaceType type) {
    final name = type.element.name;
    final lib = type.element.library;

    if (lib.identifier == 'package:jaspr/src/framework/framework.dart') {
      if (name == 'Component') return true;
    }
    if (type.superclass?.accept(this) ?? false) {
      return true;
    }
    if (type.interfaces.any((t) => t.accept(this))) {
      return true;
    }
    return false;
  }
}

extension Indent on String {
  String reIndent(int delta, {bool skipFirst = false}) {
    final lines = split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (i == 0 && skipFirst) continue;
      if (delta > 0) {
        lines[i] = ''.padLeft(delta) + lines[i];
      } else {
        lines[i] = lines[i].substring(-delta);
      }
    }
    return lines.join('\n');
  }
}

YamlMap? readJasprConfig(String filePath) {
  final segments = path.split(filePath);
  while (segments.length > 1) {
    final pubspecFile = File(path.joinAll([...segments, 'pubspec.yaml']));
    if (pubspecFile.existsSync()) {
      final pubspecData = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
      return pubspecData['jaspr'] as YamlMap?;
    }
    segments.removeLast();
  }
  return null;
}

extension AstSourceRange on AstNode {
  SourceRange get sourceRange => SourceRange(offset, length);
}

extension TokenSourceRange on Token {
  SourceRange get sourceRange => SourceRange(offset, length);
}
