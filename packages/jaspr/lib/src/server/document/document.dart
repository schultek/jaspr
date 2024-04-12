library document;

import 'dart:async';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

import '../../../server.dart';
import '../adapters/element_boundary_adapter.dart';
import '../child_nodes.dart';

export '../../components/style.dart' hide Style;

part 'base_document.dart';
part 'template_document.dart';

// only allow a single document
const _documentKey = GlobalKey();

abstract class Document extends StatelessComponent {
  const Document._() : super(key: _documentKey);

  const factory Document({
    String? title,
    String? base,
    String? charset,
    String? viewport,
    Map<String, String>? meta,
    List<StyleRule>? styles,
    List<Component> head,
    required Component body,
  }) = _BaseDocument;

  const factory Document.template({
    String name,
    String attachTo,
    required Component child,
  }) = _TemplateDocument;
}
