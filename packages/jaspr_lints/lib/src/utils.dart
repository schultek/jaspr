import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

bool isComponentType(DartType? type) {
  return type != null && type.accept(IsComponentVisitor());
}

bool isStylesType(DartType? type) {
  if (type == null || type is! InterfaceType) return false;
  var name = type.element.name;
  var lib = type.element.library;

  return lib.identifier == 'package:jaspr/src/foundation/styles/styles.dart' && name == 'Styles';
}

bool isComponentListType(DartType? type) {
  return type != null &&
      type.isDartCoreList &&
      (type as InterfaceType).typeArguments.first.accept(IsComponentVisitor());
}

int getLineIndent(LineInfo lineInfo, AstNode node) {
  var lineNumber = lineInfo.getLocation(node.offset).lineNumber - 1;
  var lineOffset = lineInfo.getOffsetOfLine(lineNumber);
  Token token = node.beginToken;
  while (token.previous != null && token.previous!.offset >= lineOffset) {
    token = token.previous!;
  }
  return token.offset - lineOffset;
}

bool hasClassesParameter(List<ParameterElement>? params) {
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
    var name = type.element.name;
    var lib = type.element.library;

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
    var lines = split('\n');
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

dynamic readJasprConfig(String filePath) {
  var segments = path.split(filePath);
  while (segments.length > 1) {
    var pubspecFile = File(path.joinAll([...segments, 'pubspec.yaml']));
    if (pubspecFile.existsSync()) {
      var pubspecData = loadYaml(pubspecFile.readAsStringSync());
      return pubspecData['jaspr'];
    }
    segments.removeLast();
  }
}
