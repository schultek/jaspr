import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/source_range.dart';

import '../utils.dart';

class StylesOrderingRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'styles_ordering',
    'Styles are not ordered. Try sorting them.',
  );

  StylesOrderingRule()
    : super(
        name: 'styles_ordering',
        description: 'Styles are not ordered. Try sorting them.',
      );

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final visitor = _StylesVisitor(this, context);
    registry.addMethodInvocation(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _StylesVisitor extends SimpleAstVisitor<void> {
  _StylesVisitor(this.rule, this.context);

  final StylesOrderingRule rule;
  final RuleContext context;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final fn = node.function;
    if (fn is! SimpleIdentifier || fn.name != 'styles') {
      return;
    }
    final method = fn.element;
    if (method is! MethodElement) {
      return;
    }
    final mixin = method.enclosingElement;
    if (mixin is! ClassElement || mixin.name != 'StylesMixin') {
      return;
    }

    final params = method.formalParameters.map((p) => p.name).toList();
    final arguments = node.argumentList.arguments;

    if (checkOrder(arguments, params) case final argument?) {
      rule.reportAtNode(argument);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme != 'Styles' || node.constructorName.name != null) {
      return;
    }
    if (!isStylesType(node.staticType)) {
      return;
    }
    final constructor = node.constructorName.element;
    if (constructor == null) {
      return;
    }

    final params = constructor.formalParameters.map((p) => p.name).toList();
    final arguments = node.argumentList.arguments;

    if (checkOrder(arguments, params) case final argument?) {
      rule.reportAtNode(argument);
    }
  }

  List<FormalParameterElement> findStylesOrder(InterfaceType stylesType) {
    final constructor = stylesType.constructors.where((c) => c.name == '').first;
    return constructor.formalParameters;
  }

  static Expression? checkOrder(NodeList<Expression> args, List<String?> params) {
    int lastSeenParam = -1;

    for (final argument in args) {
      if (argument is! NamedExpression) {
        continue;
      }
      final paramIndex = params.indexOf(argument.name.label.name);
      if (paramIndex == -1) {
        continue;
      }
      if (paramIndex < lastSeenParam) {
        return argument;
      }
      lastSeenParam = paramIndex;
    }
    return null;
  }
}

class OrderStylesFix extends ResolvedCorrectionProducer {
  static const _sortStylesKind = FixKind(
    'jaspr.fix.sortStyles',
    DartFixKindPriority.standard,
    'Sort styles',
  );

  OrderStylesFix({required super.context});

  @override
  CorrectionApplicability get applicability => CorrectionApplicability.acrossSingleFile;

  @override
  FixKind get fixKind => _sortStylesKind;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    if (node case NamedExpression(parent: final ArgumentList arguments)) {
      if (arguments.parent case final InstanceCreationExpression node) {
        final constructor = node.constructorName.element;
        if (constructor == null) {
          return;
        }

        final params = constructor.formalParameters.map((p) => p.name).toList();
        final arguments = node.argumentList.arguments;

        await _sortStyles(builder, arguments, params);
      } else if (arguments.parent case final MethodInvocation node) {
        final fn = node.function;
        if (fn is! SimpleIdentifier) {
          return;
        }
        final method = fn.element;
        if (method is! MethodElement) {
          return;
        }

        final params = method.formalParameters.map((p) => p.name).toList();
        final arguments = node.argumentList.arguments;

        await _sortStyles(builder, arguments, params);
      }
    }
  }

  Future<void> _sortStyles(ChangeBuilder builder, NodeList<Expression> arguments, List<String?> params) async {
    await builder.addDartFileEdit(file, (builder) {
      final start = arguments.beginToken!.offset;
      final end = arguments.endToken!.end;

      final breaks = <String>[];

      for (var i = 0; i < arguments.length - 1; i++) {
        breaks.add(getRangeText(SourceRange(arguments[i].end, arguments[i + 1].offset - arguments[i].end)));
      }

      final args = [...arguments]
        ..sort((a, b) {
          if (a is NamedExpression && b is NamedExpression) {
            return params.indexOf(a.name.label.name).compareTo(params.indexOf(b.name.label.name));
          }
          return 0;
        });

      final argSources = args.map((a) => getRangeText(SourceRange(a.offset, a.length))).toList();

      builder.addReplacement(SourceRange(start, end - start), (edit) {
        for (var i = 0; i < args.length; i++) {
          edit.write(argSources[i]);
          if (i < breaks.length) edit.write(breaks[i]);
        }
      });
    });
  }
}
