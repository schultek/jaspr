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
    "Prefer using '{0}(...)' over '{1}.element(tag: \"{0}\", ...)'.",
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
    registry.addDotShorthandConstructorInvocation(this, visitor);
    registry.addDotShorthandInvocation(this, visitor);
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
    if (node.constructorName.name?.name == 'element') {
      final tag = _tagArgumentValue(node.argumentList);
      if (tag == null || !allHtmlTags.contains(tag)) {
        return;
      }
      rule.reportAtNode(node.constructorName, arguments: [tag, 'Component']);
    }
  }

  @override
  void visitDotShorthandConstructorInvocation(DotShorthandConstructorInvocation node) {
    if (!isComponentType(node.staticType)) {
      return;
    }
    if (node.constructorName.name == 'element') {
      final tag = _tagArgumentValue(node.argumentList);
      if (tag == null || !allHtmlTags.contains(tag)) {
        return;
      }
      rule.reportAtSourceRange(range.startEnd(node.period, node.constructorName), arguments: [tag, '']);
    }
  }

  @override
  void visitDotShorthandInvocation(DotShorthandInvocation node) {
    if (!isComponentType(node.staticType)) {
      return;
    }
    if (node.memberName.name == 'element') {
      final tag = _tagArgumentValue(node.argumentList);
      if (tag == null || !allHtmlTags.contains(tag)) {
        return;
      }
      rule.reportAtSourceRange(range.startEnd(node.period, node.memberName), arguments: [tag, '']);
    }
  }
}

class ConvertHtmlComponentFix extends ResolvedCorrectionProducer {
  static const _convertComponentKind = FixKind(
    'jaspr.fix.useHtmlComponent',
    DartFixKindPriority.standard,
    'Convert to {0}() component',
  );

  static const _convertComponentAllKind = FixKind(
    'jaspr.fix.useHtmlComponent.all',
    DartFixKindPriority.standard,
    'Convert to html components everywhere in file',
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
  FixKind? get multiFixKind => _convertComponentAllKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final (ArgumentList argumentList, SourceRange nameRange)? target = switch (node) {
      ConstructorName(parent: final InstanceCreationExpression expr) => (
        expr.argumentList,
        range.node(node),
      ),
      final InstanceCreationExpression expr => (
        expr.argumentList,
        range.node(expr.constructorName),
      ),
      final DotShorthandConstructorInvocation expr => (
        expr.argumentList,
        range.startEnd(expr.period, expr.constructorName),
      ),
      SimpleIdentifier(parent: final DotShorthandConstructorInvocation expr) => (
        expr.argumentList,
        range.startEnd(expr.period, expr.constructorName),
      ),
      final DotShorthandInvocation expr => (
        expr.argumentList,
        range.startEnd(expr.period, expr.memberName),
      ),
      SimpleIdentifier(parent: final DotShorthandInvocation expr) => (
        expr.argumentList,
        range.startEnd(expr.period, expr.memberName),
      ),
      _ => null,
    };

    if (target == null) {
      return;
    }
    final (argumentList, nameRange) = target;

    final tag = _tagArgumentValue(argumentList);
    if (tag == null) {
      return;
    }
    _tagName = tag;

    await builder.addDartFileEdit(file, (builder) {
      for (final argument in argumentList.arguments) {
        if (argument is NamedArgument) {
          final name = argument.name.lexeme;
          if (name == 'tag') {
            int end;
            if (argument.endToken.next case final next? when next.lexeme == ',') {
              end = next.next?.offset ?? next.end;
            } else {
              end = argument.endToken.next?.offset ?? argument.end;
            }
            builder.addDeletion(range.startOffsetEndOffset(argument.offset, end));
          } else if (name == 'children') {
            builder.addDeletion(range.startStart(argument.name, argument.argumentExpression));
          }
        }
      }

      builder.addSimpleReplacement(nameRange, tag);
    });
  }
}

/// Returns the value of the named 'tag' argument when it is a string literal.
String? _tagArgumentValue(ArgumentList argumentList) {
  if (argumentList.namedArgument('tag')?.argumentExpression case SimpleStringLiteral(:final value)) {
    return value;
  }

  return null;
}
