// ignore_for_file: file_names

import 'package:jaspr/jaspr.dart';

import '../../../../components/code_window/code_window.dart';
import '../../../../components/icon.dart';
import '../../../../constants/theme.dart';
import '../components/devex_box.dart';

class Analyze extends StatelessComponent {
  const Analyze({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DevexBox(
      caption: 'ANALYZE',
      title: 'Linter and Code Completions',
      description:
          text('Jaspr comes with its own lints and code completions to boost your productivity during development.'),
      preview: div(classes: 'analyze-preview', [
        div([
          div([
            CodeWindow(
              name: 'app.dart',
              framed: false,
              scroll: false,
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
      ]),
    );
  }

  @css
  static final List<StyleRule> styles = [
    css('.analyze-preview', [
      css('&').styles(
        padding: Padding.all(1.rem),
        height: 100.percent,
        boxSizing: BoxSizing.borderBox,
        position: Position.relative(),
      ),
      css('& > div').styles(
        position: Position.absolute(top: 50.percent, left: 47.percent),
        width: 28.rem,
        maxWidth: 100.percent,
        transform: Transform.translate(x: (-50).percent, y: (-50).percent),
      ),
      css('.quick-select  span.hljs-title:last-child').styles(
        backgroundColor: primaryFaded,
      ),
      css('& > div > div').styles(
        position: Position.relative(),
      ),
      css('.quick-actions', [
        css('&').styles(
          position: Position.absolute(right: (-1.5).rem, top: 4.rem),
          radius: BorderRadius.circular(8.px),
          border: Border(color: borderColor2, width: 1.px),
          padding: Padding.symmetric(horizontal: .2.rem, vertical: .5.rem),
          raw: {'width': 'max-content'},
          display: Display.flex,
          flexDirection: FlexDirection.column,
          alignItems: AlignItems.stretch,
          gap: Gap(row: .2.rem),
          backgroundColor: surfaceLow,
          fontSize: .8.rem,
          color: textBlack,
        ),
        css('& > span:first-child').styles(
          fontWeight: FontWeight.w600,
          color: textDim,
        ),
        css('& > span').styles(
          display: Display.flex,
          flexDirection: FlexDirection.row,
          alignItems: AlignItems.center,
          gap: Gap(column: 0.2.rem),
          padding: Padding.symmetric(horizontal: 0.5.rem, vertical: 0.2.rem),
          radius: BorderRadius.circular(4.px),
          textAlign: TextAlign.left,
        ),
        css('& > span:nth-child(2)').styles(
          backgroundColor: hoverOverlayColor,
        ),
      ]),
    ]),
  ];
}
