import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'src/assists/component_assist.dart';
import 'src/assists/css_assist.dart';
import 'src/assists/import_assist.dart';
import 'src/assists/tree_assist.dart';
import 'src/lints/prefer_html_method_lint.dart';
import 'src/lints/prefer_styles_getter.dart';
import 'src/lints/sort_children_properties_last_lint.dart';
import 'src/lints/styles_ordering_lint.dart';

PluginBase createPlugin() => JasprLinter();

class JasprLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        SortChildrenPropertiesLastLint(),
        PreferHtmlMethodLint(),
        StylesOrderingLint(),
        PreferStylesGetterLint(),
      ];

  @override
  List<Assist> getAssists() => [
        ComponentAssistProvider(),
        TreeAssistProvider(),
        CssAssistProvider(),
        ImportAssistProvider(),
      ];
}
