import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';

const String generationHeader = "// GENERATED FILE, DO NOT MODIFY\n"
"// Generated with jaspr_builder\n";

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