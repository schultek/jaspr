import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../../../models/api_models.dart';
import '../../../providers/docu_provider.dart';
import '../../elements/markdown.dart';

class DocumentPanel extends StatelessComponent {
  const DocumentPanel({super.key});

  @override
  Component build(BuildContext context) {
    var info = context.watch(activeDocumentationProvider);
    if (info == null) {
      return .text('');
    }
    return _DocumentHintMarkdown(info);
  }
}

class _DocumentHintMarkdown extends StatefulComponent {
  const _DocumentHintMarkdown(this.info);

  final HoverInfo info;

  @override
  State<_DocumentHintMarkdown> createState() => __DocumentHintMarkdownState();
}

class __DocumentHintMarkdownState extends State<_DocumentHintMarkdown> {
  late String markdown;

  @override
  void initState() {
    super.initState();
    markdown = _getMarkdownFor(component.info);
  }

  @override
  void didUpdateComponent(covariant _DocumentHintMarkdown oldComponent) {
    super.didUpdateComponent(oldComponent);
    markdown = _getMarkdownFor(component.info);
  }

  @override
  Component build(BuildContext context) {
    return p(classes: 'documentation custom-scrollbar', [Markdown(markdown: markdown)]);
  }

  String _getMarkdownFor(HoverInfo info) {
    if (info.description == null && info.dartdoc == null) {
      return '';
    }

    final libraryName = info.libraryName;
    final kind = info.kind!;
    final hasDartdoc = info.dartdoc != null;
    final isVariable = kind.contains('variable');

    final apiLink = _dartApiLink(libraryName);

    final propagatedType = info.propagatedType;
    final mdDocs =
        '''### `${info.description?.replaceAll('\n', ' ')}`\n\n
${hasDartdoc ? "${info.dartdoc}\n\n" : ''}
${isVariable ? "$kind\n\n" : ''}
${(isVariable && propagatedType != null) ? "**Propagated type:** $propagatedType\n\n" : ''}
$apiLink\n\n''';

    // Append a 'launch' icon to the 'Open library docs' link.
    //_htmlDocs = _htmlDocs.replaceAll('library docs</a>', "library docs <span class='launch-icon'></span></a>");

    return mdDocs;
  }

  String _dartApiLink(String? libraryName) {
    if (libraryName == null || libraryName.isEmpty || libraryName == 'main.dart') {
      return '';
    }

    final isDartLibrary = libraryName.contains('dart:');

    // Only can link to library docs for dart libraries.
    if (isDartLibrary) {
      final apiLink = StringBuffer('[Open library docs](');
      apiLink.write('https://api.dart.dev/stable');

      libraryName = libraryName.replaceAll(':', '-');
      apiLink.write('/$libraryName/$libraryName-library.html)');

      return apiLink.toString();
    }

    return libraryName;
  }
}
