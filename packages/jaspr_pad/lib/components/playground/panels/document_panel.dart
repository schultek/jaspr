import 'dart:convert' as convert;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:markdown/markdown.dart' as markdown;

import '../../../models/api_models.dart';
import '../../../providers/docu_provider.dart';
import '../../elements/markdown.dart';

class DocumentPanel extends StatelessComponent {
  const DocumentPanel({Key? key}) : super(key: key);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var info = context.watch(activeDocumentationProvider);
    if (info == null) {
      return;
    }
    yield _DocumentHintMarkdown(info);
  }
}

class _DocumentHintMarkdown extends StatefulComponent {
  const _DocumentHintMarkdown(this.info, {Key? key}) : super(key: key);

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
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      classes: ['documentation', 'custom-scrollbar'],
      child: Markdown(markdown: markdown, inlineSyntaxes: [InlineBracketsColon(), InlineBrackets()]),
    );
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
    final _mdDocs = '''### `${info.description?.replaceAll('\n', ' ')}`\n\n
${hasDartdoc ? "${info.dartdoc}\n\n" : ''}
${isVariable ? "$kind\n\n" : ''}
${(isVariable && propagatedType != null) ? "**Propagated type:** $propagatedType\n\n" : ''}
$apiLink\n\n''';

    // Append a 'launch' icon to the 'Open library docs' link.
    //_htmlDocs = _htmlDocs.replaceAll('library docs</a>', "library docs <span class='launch-icon'></span></a>");

    return _mdDocs;
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

class InlineBracketsColon extends markdown.InlineSyntax {
  InlineBracketsColon() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  String htmlEscape(String text) => convert.htmlEscape.convert(text);

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final element = markdown.Element.text('code', htmlEscape(match[1]!));
    parser.addNode(element);
    return true;
  }
}

// TODO: [someCodeReference] should be converted to for example
// https://api.dartlang.org/apidocs/channels/stable/dartdoc-viewer/dart:core.someReference
// for now it gets converted <code>someCodeReference</code>
class InlineBrackets extends markdown.InlineSyntax {
  // This matches URL text in the documentation, with a negative filter
  // to detect if it is followed by a URL to prevent e.g.
  // [text] (http://www.example.com) getting turned into
  // <code>text</code> (http://www.example.com)
  InlineBrackets() : super(r'\[\s?((?:.|\n)*?)\s?\](?!\s?\()');

  String htmlEscape(String text) => convert.htmlEscape.convert(text);

  @override
  bool onMatch(markdown.InlineParser parser, Match match) {
    final element = markdown.Element.text('code', '<em>${htmlEscape(match[1]!)}</em>');
    parser.addNode(element);
    return true;
  }
}
