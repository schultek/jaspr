// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';
import 'package:website/components/feature_box.dart';

class DevExp extends StatelessComponent {
  const DevExp({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield section(id: 'devexp', [
      span(classes: 'caption text-gradient', [text('Developer Experience')]),
      h2([text('The productivity of Dart'), br(), text('brought to the Web')]),
      div(classes: 'feature-grid', [
        div([
          FeatureBox(
            caption: 'DEVELOP',
            title: 'Familiar Concepts',
            description: text(
                'Apply your Flutter skills to build websites. Reuse already learned concepts like setState, BuildContext, State Management and more.'),
            preview: div([]),
          ),
          FeatureBox(
            caption: 'RUN',
            title: 'Jaspr CLI',
            description: text('Create, serve and build your site using simple cli commands.'),
            preview: div([]),
          ),
        ]),
        div([
          FeatureBox(
            caption: 'INTEGRATE',
            title: 'Packages and Plugins',
            description: Fragment(children: [
              text('Import any Dart package from pub.dev or even use '),
              b([
                a(
                    href: 'https://pub.dev/packages?q=is%3Aplugin+platform%3Aweb',
                    classes: 'animated-underline',
                    [text('Flutter web plugins')])
              ]),
              text(' through Jasprs custom compiler pipeline.'),
            ]),
            preview: div([]),
          ),
          FeatureBox(
            caption: 'ANALYZE',
            title: 'Linter and Code Completions',
            description: text(
                'Jaspr comes with its own lints and code completions to boost your productivity during development.'),
            preview: div([]),
          ),
        ]),
      ]),
    ]);
  }

  @css
  static final List<StyleRule> styles = [
    css('#devexp', [
      css('&')
          .box(padding: EdgeInsets.only(top: 10.rem))
          .flexbox(direction: FlexDirection.column, alignItems: AlignItems.center)
          .text(align: TextAlign.center),
      css('.feature-grid', [
        css('&')
            .box(
              maxWidth: 60.rem,
              margin: EdgeInsets.only(top: 3.rem),
              padding: EdgeInsets.symmetric(horizontal: 2.rem),
            )
            .flexbox(direction: FlexDirection.column, gap: Gap(row: 2.rem)),
        css('& > div', [
          css('&').flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap, gap: Gap.all(2.rem)),
          css('& > *').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(16.rem))),
          css('&:first-child > *:first-child').raw({'flex-basis': '25rem'}),
          css('&:last-child > *:last-child').raw({'flex-basis': '22rem'}),
        ]),
      ])
    ]),
  ];
}
