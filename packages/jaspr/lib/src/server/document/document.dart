library document;

import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:html/parser.dart';

import '../../../jaspr.dart';
import '../markup_render_object.dart';

export '../../components/style.dart' hide Style;

part 'base_document.dart';
part 'component_observer.dart';
part 'document_binding.dart';
part 'file_document.dart';

// only allow a single document
const _documentKey = GlobalKey();

abstract class Document extends StatefulComponent {
  const Document._() : super(key: _documentKey);

  const factory Document({
    String? title,
    String? base,
    String? charset,
    String? viewport,
    Map<String, String>? meta,
    List<StyleRule>? styles,
    String? scriptName,
    List<Component> head,
    required Component body,
  }) = _BaseDocument;

  const factory Document.file({
    String name,
    String attachTo,
    required Component child,
  }) = _FileDocument;
}

final _chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
String _randomId() {
  var r = Random();
  return List.generate(8, (i) => _chars[r.nextInt(_chars.length)]).join();
}
