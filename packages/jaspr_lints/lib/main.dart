import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

import 'src/assists/component_assist.dart';
import 'src/assists/css_assist.dart';
import 'src/assists/import_assist.dart';
import 'src/assists/tree_assist.dart';
import 'src/rules/prefer_html_components_rule.dart';
import 'src/rules/prefer_styles_getter_rule.dart';
import 'src/rules/sort_children_last_rule.dart';
import 'src/rules/styles_ordering_rule.dart';

final plugin = JasprPlugin();

class JasprPlugin extends Plugin {
  @override
  String get name => 'Jaspr plugin';

  @override
  void register(PluginRegistry registry) {
    registry.registerLintRule(SortChildrenLastRule());
    registry.registerFixForRule(SortChildrenLastRule.code, SortChildrenLastFix.new);

    registry.registerLintRule(PreferHtmlComponentsRule());
    registry.registerFixForRule(PreferHtmlComponentsRule.code, ConvertHtmlComponentFix.new);

    registry.registerLintRule(StylesOrderingRule());
    registry.registerFixForRule(StylesOrderingRule.code, OrderStylesFix.new);

    registry.registerWarningRule(PreferStylesGetterRule());
    registry.registerFixForRule(PreferStylesGetterRule.code, ReplaceWithGetterFix.new);

    registry.registerAssist(CreateStatelessComponent.new);
    registry.registerAssist(CreateStatefulComponent.new);
    registry.registerAssist(CreateInheritedComponent.new);
    registry.registerAssist(ConvertToStatefulComponent.new);
    registry.registerAssist(ConvertToAsyncStatelessComponent.new);

    registry.registerAssist(AddStyles.new);
    registry.registerAssist(ConvertToNestedStyles.new);

    registry.registerAssist(ConvertToWebImport.new);
    registry.registerAssist(ConvertToServerImport.new);

    registry.registerAssist(WrapWithHtml.new);
    registry.registerAssist(WrapWithComponent.new);
    registry.registerAssist(WrapWithBuilder.new);
    registry.registerAssist(RemoveComponent.new);
    registry.registerAssist(ExtractComponent.new);
  }
}
