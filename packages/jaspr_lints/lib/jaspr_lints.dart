import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:jaspr_lints/src/assists/css_assist.dart';
import 'package:jaspr_lints/src/assists/import_assist.dart';
import 'package:jaspr_lints/src/lints/prefer_html_method_lint.dart';
import 'package:jaspr_lints/src/lints/sort_children_properties_last_lint.dart';

import 'src/assists/component_assist.dart';
import 'src/assists/tailwind_assist.dart';
import 'src/assists/tree_assist.dart';

PluginBase createPlugin() => JasprLinter();

class JasprLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        SortChildrenPropertiesLastLint(),
        PreferHtmlMethodLint(),
      ];

  @override
  List<Assist> getAssists() => [
        ComponentAssistProvider(),
        TreeAssistProvider(),
        TailwindAssistProvider(),
        CssAssistProvider(),
        ImportAssistProvider(),
      ];
}
