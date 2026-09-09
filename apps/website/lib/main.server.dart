import 'package:jaspr/server.dart';
import 'package:jaspr_content/jaspr_content.dart';
import 'package:jaspr_content/theme.dart';

import 'layouts/home_layout.dart';
import 'layouts/imprint_layout.dart';
import 'main.server.options.dart';
import 'pages/case_study/case_study.dart';
import 'pages/consulting/consulting.dart';
import 'pages/content/jaspr_content.dart';
import 'pages/home/home.dart';
import 'pages/showcase/showcase_page.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    ContentApp(
      parsers: [
        MarkdownParser(),
      ],
      components: [
        CustomComponent(pattern: 'Home', builder: (name, attrs, child) => Home()),
        CustomComponent(pattern: 'Consulting', builder: (name, attrs, child) => Consulting()),
        CustomComponent(pattern: 'Showcase', builder: (name, attrs, child) => ShowcasePage()),
        CustomComponent(pattern: 'JasprContent', builder: (name, attrs, child) => JasprContent()),
        CustomComponent(pattern: 'CaseStudy', builder: (name, attrs, child) => CaseStudy()),
      ],
      layouts: [
        HomeLayout(),
        ImprintLayout(),
      ],
      theme: ContentTheme.none(),
    ),
  );
}
