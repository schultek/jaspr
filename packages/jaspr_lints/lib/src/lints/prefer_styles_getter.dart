import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class PreferStylesGetterLint extends DartLintRule {
  PreferStylesGetterLint()
      : super(
          code: LintCode(
            name: 'prefer_styles_getter',
            problemMessage: "Prefer using a getter over a variable declaration for style rules to support hot-reload.",
          ),
        );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addVariableDeclarationList((node) {
      if (node.variables.length != 1) return;
      if (node.parent
          case TopLevelVariableDeclaration(metadata: var metadata, firstTokenAfterCommentAndMetadata: var token) ||
              FieldDeclaration(metadata: var metadata, isStatic: true, firstTokenAfterCommentAndMetadata: var token)
          when metadata.any(checkCss)) {
        final start = token.offset;
        final end = node.variables.first.name.end;
        reporter.atOffset(offset: start, length: end - start, errorCode: code, data: node);
      }
    });
  }

  bool checkCss(Annotation a) {
    return a.name.name == 'css' &&
        a.name.staticElement?.librarySource?.uri.toString() == 'package:jaspr/src/foundation/styles/css.dart';
  }

  @override
  List<Fix> getFixes() => [ReplaceWithGetterFix()];
}

class ReplaceWithGetterFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    if (analysisError.data case VariableDeclarationList node) {
      reporter.createChangeBuilder(message: 'Replace with getter', priority: 1).addDartFileEdit((builder) {
        final start = node.firstTokenAfterCommentAndMetadata.offset;
        final end = node.variables.first.equals!.end;
        builder.addReplacement(SourceRange(start, end - start), (edit) {
          edit.write(node.type?.toSource() ?? 'List<StyleRule>');
          edit.write(' get ');
          edit.write(node.variables.first.name.lexeme);
          edit.write(' =>');
        });
      });
    }
  }
}
