import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';

import '../utils.dart';

class PreferStylesGetterRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_styles_getter',
    "Prefer using a getter over a variable declaration for style rules to support hot-reload.",
  );

  PreferStylesGetterRule()
    : super(
        name: 'prefer_styles_getter',
        description: 'Prefer using a getter over a variable declaration for style rules to support hot-reload.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    var visitor = _StylesVisitor(this, context);
    registry.addVariableDeclarationList(this, visitor);
  }
}

class _StylesVisitor extends SimpleAstVisitor<void> {
  _StylesVisitor(this.rule, this.context);

  final PreferStylesGetterRule rule;
  final RuleContext context;

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    if (node.variables.length != 1) return;
    if (node.parent
        case TopLevelVariableDeclaration(
              metadata: final metadata,
              firstTokenAfterCommentAndMetadata: final token,
            ) ||
            FieldDeclaration(
              isStatic: true,
              metadata: final metadata,
              firstTokenAfterCommentAndMetadata: final token,
            )) {
      if (!metadata.any(checkCss)) {
        return;
      }
      final start = token.offset;
      final end = node.variables.first.name.end;
      rule.reportAtOffset(start, end - start);
    }
  }

  bool checkCss(Annotation a) {
    return a.name.name == 'css' &&
        a.name.element?.library?.firstFragment.source.uri.toString() == 'package:jaspr/src/dom/styles/css.dart';
  }
}

class ReplaceWithGetterFix extends ResolvedCorrectionProducer {
  static const _replaceWithGetterKind = FixKind(
    'jaspr.fix.replaceWithGetter',
    DartFixKindPriority.standard,
    "Replace with getter",
  );

  ReplaceWithGetterFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _replaceWithGetterKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final VariableDeclarationList node || FieldDeclaration(fields: final node)) {
      await builder.addDartFileEdit(file, (builder) {
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
