import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../../components/case_study_card.dart';
import '../../../constants/theme.dart';

class CaseStudyTeaser extends StatelessComponent {
  const CaseStudyTeaser({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'case-study', [
      div(classes: 'case-study-container', [
        CaseStudyCard(),
      ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('#case-study', [
      css('&').styles(
        display: .flex,
        padding: .only(top: 1.rem),
        justifyContent: .center,
        alignItems: .center,
        boxSizing: .borderBox,
      ),
      css('.case-study-container').styles(
        width: 100.percent,
        maxWidth: maxContentWidth,
        padding: .symmetric(horizontal: contentPadding),
        boxSizing: .borderBox,
      ),
    ]),
  ];
}
