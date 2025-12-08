import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/source_range.dart';

import '../utils.dart';

class SortChildrenLastRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'sort_children_last',
    'Sort children last in html components.',
  );

  SortChildrenLastRule()
    : super(
        name: 'sort_children_last',
        description: 'Sort children last in html components.',
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

  final SortChildrenLastRule rule;
  final RuleContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isComponentType(node.staticType)) {
      return;
    }
    ListLiteral? childrenArg;
    var violatesLint = false;
    for (var argument in node.argumentList.arguments) {
      if (argument is ListLiteral && isComponentListType(argument.staticType)) {
        childrenArg = argument;
      } else if (childrenArg != null && argument is NamedExpression) {
        violatesLint = true;
      }
    }
    if (violatesLint) {
      rule.reportAtNode(node);
    }
  }
}

class SortChildrenLastFix extends ResolvedCorrectionProducer {
  static const _sortChildrenKind = FixKind(
    'jaspr.fix.sortChildrenLast',
    DartFixKindPriority.standard,
    'Sort children last',
  );

  SortChildrenLastFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _sortChildrenKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case final InstanceCreationExpression node) {
      final childrenArg = node.argumentList.arguments.whereType<ListLiteral>().firstWhere(
        (element) => isComponentListType(element.staticType),
      );

      await builder.addDartFileEdit(file, (builder) {
        final nextArg = node.argumentList.arguments[node.argumentList.arguments.indexOf(childrenArg) + 1];

        final start = childrenArg.end;
        final argStart = nextArg.offset;
        final end = node.argumentList.arguments.last.end;

        final divider = getRangeText(SourceRange(start, argStart - start));
        final args = getRangeText(SourceRange(argStart, end - argStart));

        builder.addInsertion(childrenArg.offset, (edit) {
          edit.write(args);
          edit.write(divider);
        });

        builder.addDeletion(SourceRange(start, end - start));
      });
    }
  }
}
