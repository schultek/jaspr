import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class StylesOrderingLint extends DartLintRule {
  StylesOrderingLint()
      : super(
          code: LintCode(
            name: 'styles_ordering',
            problemMessage: "Styles are not ordered. Try sorting them.",
          ),
        );

  @override
  void run(CustomLintResolver resolver, ErrorReporter reporter, CustomLintContext context) {
    context.registry.addInvocationExpression((node) {
      var fn = node.function;
      if (fn is! SimpleIdentifier || fn.name != 'styles') {
        return;
      }
      var method = fn.staticElement?.declaration;
      if (method is! MethodElement) {
        return;
      }
      var mixin = method.enclosingElement3;
      if (mixin is! ClassElement || mixin.name != 'StylesMixin') {
        return;
      }

      final params = method.parameters.map((p) => p.name).toList();

      var violatesOrder = !isOrdered(node.argumentList.arguments, params);
      if (violatesOrder) {
        reporter.atOffset(
          offset: node.argumentList.arguments.beginToken!.offset,
          length: node.argumentList.arguments.endToken!.end - node.argumentList.arguments.beginToken!.offset,
          errorCode: code,
          data: (node, params),
        );
      }
    });
  }

  @override
  List<Fix> getFixes() => [OrderStylesFix()];

  List<ParameterElement> findStylesOrder(InterfaceType stylesType) {
    final constructor = stylesType.constructors.where((c) => c.name == '').first;
    return constructor.parameters;
  }

  static bool isOrdered(NodeList<Expression> args, List<String> params) {
    int lastSeenParam = -1;
    var violatesOrder = false;

    for (var argument in args) {
      if (argument is! NamedExpression) {
        continue;
      }
      var paramIndex = params.indexOf(argument.name.label.name);
      if (paramIndex == -1) {
        continue;
      }
      if (paramIndex < lastSeenParam) {
        violatesOrder = true;
        break;
      }
      lastSeenParam = paramIndex;
    }
    return !violatesOrder;
  }
}

class OrderStylesFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    if (analysisError.data case (InvocationExpression node, List<String> params)) {
      var violatesOrder = !StylesOrderingLint.isOrdered(node.argumentList.arguments, params);
      if (!violatesOrder) {
        return;
      }

      reporter.createChangeBuilder(message: 'Sort styles', priority: 2).addDartFileEdit((builder) {
        var arguments = node.argumentList.arguments;
        var content = resolver.source.contents.data;

        var start = arguments.beginToken!.offset;
        var end = arguments.endToken!.end;

        var breaks = <String>[];

        for (var i = 0; i < arguments.length - 1; i++) {
          breaks.add(content.substring(arguments[i].end, arguments[i + 1].offset));
        }

        var args = <NamedExpression>[...arguments.cast<NamedExpression>()]
          ..sort((a, b) => params.indexOf(a.name.label.name).compareTo(params.indexOf(b.name.label.name)));

        var argSources = args.map((a) => a.toSource()).toList();

        builder.addReplacement(SourceRange(start, end - start), (edit) {
          for (var i = 0; i < args.length; i++) {
            edit.write(argSources[i]);
            if (i < breaks.length) edit.write(breaks[i]);
          }
        });
      });
    }
  }
}
