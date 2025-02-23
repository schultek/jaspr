import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart' show AnalysisError;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

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
      final arguments = node.argumentList.arguments;

      var violatesOrder = !isOrdered(arguments, params);
      if (violatesOrder) {
        reporter.atOffset(
          offset: arguments.beginToken!.offset,
          length: arguments.endToken!.end - arguments.beginToken!.offset,
          errorCode: code,
          data: (arguments, params),
        );
      }
    });

    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.name2.lexeme != 'Styles' || node.constructorName.name != null) {
        return;
      }
      if (!isStylesType(node.staticType)) {
        return;
      }
      var constructor = node.constructorName.staticElement;
      if (constructor == null) {
        return;
      }

      final params = constructor.parameters.map((p) => p.name).toList();
      final arguments = node.argumentList.arguments;

      var violatesOrder = !isOrdered(arguments, params);
      if (violatesOrder) {
        reporter.atOffset(
          offset: arguments.beginToken!.offset,
          length: arguments.endToken!.end - arguments.beginToken!.offset,
          errorCode: code,
          data: (arguments, params),
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
    if (analysisError.data case (NodeList<Expression> arguments, List<String> params)) {
      var violatesOrder = !StylesOrderingLint.isOrdered(arguments, params);
      if (!violatesOrder) {
        return;
      }

      reporter.createChangeBuilder(message: 'Sort styles', priority: 2).addDartFileEdit((builder) {
        var content = resolver.source.contents.data;

        var start = arguments.beginToken!.offset;
        var end = arguments.endToken!.end;

        var breaks = <String>[];

        for (var i = 0; i < arguments.length - 1; i++) {
          breaks.add(content.substring(arguments[i].end, arguments[i + 1].offset));
        }

        var args = [...arguments]..sort((a, b) {
            if (a is NamedExpression && b is NamedExpression) {
              return params.indexOf(a.name.label.name).compareTo(params.indexOf(b.name.label.name));
            }
            return 0;
          });

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
