import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';
import '../all_html_tags.dart';
import '../utils.dart';

enum ComponentType { text, element, fragment }

class PreferHtmlComponentsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'prefer_html_components',
    "Prefer using '{0}(...)' over 'Component.element(tag: \"{0}\", ...)'.",
  );

  PreferHtmlComponentsRule()
    : super(
        name: 'prefer_html_components',
        description: "Prefer using html components over the 'Component.element' constructor.",
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _HtmlComponentVisitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _HtmlComponentVisitor extends SimpleAstVisitor<void> {
  _HtmlComponentVisitor(this.rule, this.context);

  final PreferHtmlComponentsRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme != 'Component') {
      return;
    }
    if (!isComponentType(node.staticType)) {
      return;
    }
    if (node.isConst) {
      // Allow when used with const.
      return;
    }
    if (node.constructorName.name?.name == 'element') {
      final tag = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((n) => n.name.label.name == 'tag')
          .map((n) => n.expression)
          .whereType<SimpleStringLiteral>()
          .firstOrNull
          ?.value;
      if (tag == null || !allHtmlTags.contains(tag)) {
        return;
      }
      rule.reportAtNode(node.constructorName, arguments: [tag]);
    }
  }
}

class ConvertHtmlComponentFix extends ResolvedCorrectionProducer {
  static const _convertComponentKind = FixKind(
    'jaspr.fix.useHtmlComponent',
    DartFixKindPriority.standard,
    'Convert to {0}() component',
  );

  ConvertHtmlComponentFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _convertComponentKind;

  @override
  List<String>? get fixArguments => [_tagName];

  late String _tagName;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case ConstructorName(parent: final InstanceCreationExpression node)) {
      final tag = node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((n) => n.name.label.name == 'tag')
          .map((n) => n.expression)
          .whereType<SimpleStringLiteral>()
          .firstOrNull
          ?.value;
      if (tag == null) {
        return;
      }
      _tagName = tag;

      await builder.addDartFileEdit(file, (builder) {
        for (final argument in node.argumentList.arguments) {
          if (argument is NamedExpression) {
            final name = argument.name.label.name;
            if (name == 'tag') {
              int end;
              if (argument.endToken.next case final next? when next.lexeme == ',') {
                end = next.next?.offset ?? next.end;
              } else {
                end = argument.endToken.next?.offset ?? argument.end;
              }
              builder.addDeletion(SourceRange(argument.offset, end - argument.offset));
            } else if (name == 'children') {
              final end = argument.name.endToken.next?.offset ?? argument.end;
              builder.addDeletion(SourceRange(argument.name.offset, end - argument.name.offset));
            }
          }
        }

        builder.addSimpleReplacement(SourceRange(node.constructorName.offset, node.constructorName.length), tag);
      });
    }
  }
}
