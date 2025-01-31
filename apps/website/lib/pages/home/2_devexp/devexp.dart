import 'package:jaspr/jaspr.dart';
import 'package:website/pages/home/2_devexp/components/feature_box.dart';

import '../../../components/code_window/code_block.dart';
import '../../../components/code_window/code_window.dart';
import '../../../components/icon.dart';
import '../../../constants/theme.dart';
import 'components/animated_console.dart';

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
            preview: div(classes: 'develop-preview', [
              CodeWindow(
                name: 'components.dart',
                framed: false,
                source: '''
                class Button extends StatelessComponent { 
                  const Button({this.onClicked, this.child, super.key});  ...
                }

                class Counter extends StatefulComponent { ... }
                class CounterState extends State<Counter> { ... }

                class InheritedAppState extends InheritedComponent { ...}
                ''',
              ),
            ]),
          ),
          FeatureBox(
            caption: 'RUN',
            title: 'Jaspr CLI',
            description: text('Create, serve and build your site using simple cli commands.'),
            preview: div(classes: 'run-preview', [
              AnimatedConsole(),
            ]),
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
            preview: div([
              CodeBlock(
                source: '''
                name: my_awesome_website

                dependencies:
                  cloud_firestore: ^5.6.2
                  dart_mappable: ^4.3.0
                  http: ^1.3.0
                  intl: ^0.19.0
                  jaspr: ^0.17.0
                  logging: ^1.3.0
                  riverpod: ^2.6.1
                  shared_preferences: ^2.4.0
                ''',
                language: 'yaml',
              ),
            ]),
          ),
          FeatureBox(
            caption: 'ANALYZE',
            title: 'Linter and Code Completions',
            description: text(
                'Jaspr comes with its own lints and code completions to boost your productivity during development.'),
            preview: div(classes: 'analyze-preview', [
              div([
                CodeWindow(
                  name: 'app.dart',
                  framed: false,
                  source: '''
                class App extends StatelessComponent {
                  const App({super.key});

                  Iterable<Component> build(BuildContext context) sync* {
                    yield div([
                      ...
                ''',
                  lineClasses: {0: 'quick-select'},
                ),
                div(classes: 'quick-actions', [
                  span([text('Quick Actions:')]),
                  span([
                    Icon('lightbulb'),
                    span([text('Convert to StatefulComponent')])
                  ]),
                  span([
                    Icon('lightbulb'),
                    span([text('Convert to AsyncStatelessComponent')])
                  ]),
                ]),
              ]),
            ]),
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
              maxWidth: maxContentWidth,
              margin: EdgeInsets.only(top: 3.rem),
              padding: EdgeInsets.symmetric(horizontal: 2.rem),
            )
            .flexbox(direction: FlexDirection.column, gap: Gap(row: 3.rem)),
        css('& > div', [
          css('&').flexbox(direction: FlexDirection.row, wrap: FlexWrap.wrap, gap: Gap.all(3.rem)),
          css('& > *').flexItem(flex: Flex(grow: 1, shrink: 0, basis: FlexBasis(16.rem))),
          css('&:first-child > *:first-child').raw({'flex-basis': '30rem'}),
          css('&:last-child > *:last-child').raw({'flex-basis': '30rem'}),
        ]),
        css('.develop-preview', [
          css('&')
              .box(padding: EdgeInsets.all(1.rem), height: 100.percent, boxSizing: BoxSizing.borderBox)
              .flexbox(alignItems: AlignItems.center, justifyContent: JustifyContent.center),
          css('& > *').flexItem(flex: Flex(grow: 1)),
        ]),
        css('.run-preview', [
          css('&').box(padding: EdgeInsets.all(.5.rem)),
        ]),
        css('.analyze-preview', [
          css('&')
              .box(padding: EdgeInsets.all(1.rem), height: 100.percent, boxSizing: BoxSizing.borderBox)
              .flexbox(alignItems: AlignItems.center, justifyContent: JustifyContent.center),
          css('& > *').flexItem(flex: Flex(grow: 1)),
          css('.quick-select  span.hljs-title:last-child', [
            css('&').background(color: primaryFaded),
          ]),
          css('& > div', [
            css('&').box(position: Position.relative(), maxWidth: 25.rem).raw({'pointer-events': 'none'}),
          ]),
          css('.quick-actions', [
            css('&')
                .box(
                  position: Position.absolute(left: 12.5.rem, top: 4.rem),
                  radius: BorderRadius.circular(8.px),
                  border: Border.all(BorderSide(color: borderColor2, width: 1.px)),
                  padding: EdgeInsets.symmetric(horizontal: .2.rem, vertical: .5.rem),
                )
                .raw({'width': 'max-content'})
                .flexbox(direction: FlexDirection.column, alignItems: AlignItems.stretch, gap: Gap(row: .2.rem))
                .background(color: surfaceLow)
                .text(fontSize: .8.rem, color: textBlack),
            css('& > span:first-child').text(fontWeight: FontWeight.w600, color: textDim),
            css('& > span')
                .flexbox(direction: FlexDirection.row, alignItems: AlignItems.center, gap: Gap(column: 0.2.rem))
                .box(
                    padding: EdgeInsets.symmetric(horizontal: 0.5.rem, vertical: 0.2.rem),
                    radius: BorderRadius.circular(4.px))
                .text(align: TextAlign.left),
            css('& > span:nth-child(2)').background(color: hoverOverlayColor),
          ]),
        ]),
      ])
    ]),
  ];
}
