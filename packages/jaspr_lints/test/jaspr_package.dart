import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';

extension JasprAnalysisRuleTest on AnalysisRuleTest {
  void setUpJasprPackage() {
    newPackage('jaspr')
      ..addFile('lib/jaspr.dart', r'''
        export 'src/framework/framework.dart';
        export 'src/foundation/annotations.dart';
      ''')
      ..addFile('lib/dom.dart', r'''
        export 'src/dom/styles/css.dart';
        export 'src/dom/styles/styles.dart';
      ''')
      ..addFile('lib/server.dart', r'''
        export 'src/framework/framework.dart';
      ''')
      ..addFile('lib/client.dart', r'''
        export 'src/framework/framework.dart';
      ''')
      ..addFile('lib/src/framework/framework.dart', r'''
        class Component {
          const Component();
          factory Component.element({required String tag}) => Component._();
          factory Component.text(String text) => Component._();
        }

        class div extends Component {
          div(List<Component> children, {String? id, String? classes}) : super();
        }
        class p extends Component {
          p(List<Component> children, {String? id, String? classes}) : super();
        }

        abstract class StatelessComponent extends Component {
          const StatelessComponent();

          Component build(BuildContext context);
        }

        class BuildContext {}

        void runApp(Component app) {}
      ''')
      ..addFile('lib/src/dom/styles/css.dart', r'''
        import 'styles.dart';

        const css = _CssAnnotation();
        class _CssAnnotation with StylesMixin {
          const _CssAnnotation();
        } 

        class StyleRule {
          const StyleRule();
        }
      ''')
      ..addFile('lib/src/foundation/annotations.dart', r'''
        const client = _Client();
        class _Client { const _Client(); }
      ''')
      ..addFile('lib/src/dom/styles/styles.dart', r'''
        class Styles {
          const Styles({
            String? display,
            String? width,
            String? height,
            String? padding,
            String? margin,
            String? color,
            String? fontSize,
          });
        }

        mixin class StylesMixin {
          void styles({
            String? display,
            String? width,
            String? height,
            String? padding,
            String? margin,
            String? color,
            String? fontSize,
          }) {}
        }
      ''');
  }
}
