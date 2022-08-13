import 'dart:async';
import 'dart:convert';

import 'package:html/parser.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../foundation/constants.dart';
import '../foundation/scheduler.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';
import '../server/server_app.dart';

/// Main entry point on the server
void runApp(Component app, {String attachTo = 'body'}) {
  runServer(app, attachTo: attachTo);
}

/// Same as [runApp] but returns an instance of [ServerApp] to control aspects of the http server
ServerApp runServer(Component app, {String attachTo = 'body'}) {
  return ServerApp.run(() {
    AppBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
  });
}

/// Global component binding for the server
class AppBinding extends BindingBase with SchedulerBinding, ComponentsBinding, SyncBinding {
  static AppBinding ensureInitialized() {
    if (ComponentsBinding.instance == null) {
      AppBinding();
    }
    return ComponentsBinding.instance! as AppBinding;
  }

  @override
  Uri get currentUri => _currentUri!;
  Uri? _currentUri;

  void setCurrentUri(Uri uri) {
    _currentUri = uri;
  }

  String? _targetId;

  @override
  bool get isClient => false;

  final rootCompleter = Completer.sync();

  @override
  void didAttachRootElement(Element element, {required String to}) {
    _targetId = to;
    rootCompleter.complete();
  }

  @override
  Renderer attachRenderer(String to) {
    return MarkupDomRenderer();
  }

  Future<String> render(String rawHtml) async {
    await rootCompleter.future;

    var document = parse(rawHtml);
    var appElement = document.querySelector(_targetId!)!;
    appElement.innerHtml = (rootElements.values.first.renderer as MarkupDomRenderer).renderHtml();

    document.body!.attributes['state-data'] = stateCodec.encode(getStateData());
    return document.outerHtml;
  }

  Future<String> data() async {
    await rootCompleter.future;
    return jsonEncode(getStateData());
  }

  @override
  dynamic getRawState(String id) => null;

  @override
  Future<Map<String, String>> fetchState(String url) {
    throw 'Cannot fetch state on the server';
  }

  @override
  void updateRawState(String id, dynamic state) {}

  @override
  void scheduleBuild(VoidCallback buildCallback) {
    throw UnsupportedError('Scheduling a build is not supported on the server, and should never happen.');
  }
}

class DomNodeData {
  String? tag;
  String? id;
  List<String>? classes;
  Map<String, String>? styles;
  Map<String, String>? attributes;
  String? text;
  bool? rawHtml;
  List<RenderElement> children = [];
}

extension DomNodeDataExt on RenderElement {
  DomNodeData get data => getData() ?? setData(DomNodeData());
}

class MarkupDomRenderer extends Renderer {
  RenderElement? root;

  @override
  void setRootNode(RenderElement element) {
    root = element;
  }

  @override
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    element.data
      ..tag = tag
      ..id = id
      ..classes = classes
      ..styles = styles
      ..attributes = attributes;
  }

  @override
  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]) {
    element.data
      ..text = text
      ..rawHtml = rawHtml;
  }

  @override
  void skipContent(RenderElement element) {
    // noop
  }

  @override
  void renderChildNode(RenderElement element, RenderElement child, RenderElement? after) {
    var children = element.data.children;
    children.remove(child);
    if (after == null) {
      children.insert(0, child);
    } else {
      var index = children.indexOf(after);
      children.insert(index + 1, child);
    }
  }

  @override
  void didPerformRebuild(RenderElement element) {}

  @override
  void removeChild(RenderElement parent, RenderElement child) {
    parent.data.children.remove(child);
  }

  String renderHtml() {
    return root != null ? renderNodeHtml(root!) : '';
  }

  String renderNodeHtml(RenderElement element, [int inset = 0]) {
    var data = element.data;
    var insetStr = '';
    if (data.text != null) {
      if (data.rawHtml == true) {
        return insetStr + data.text!;
      } else {
        return insetStr + htmlEscape.convert(data.text!);
      }
    } else if (data.tag != null) {
      var output = StringBuffer();
      var tag = data.tag!.toLowerCase();
      _domValidator.validateElementName(tag);
      output.write('$insetStr<$tag');
      if (data.id != null) {
        output.write(' id="${_attributeEscape.convert(data.id!)}"');
      }
      if (data.classes != null && data.classes!.isNotEmpty) {
        output.write(' class="${_attributeEscape.convert(data.classes!.join(' '))}"');
      }
      if (data.styles != null && data.styles!.isNotEmpty) {
        output.write(
            ' style="${_attributeEscape.convert(data.styles!.entries.map((e) => '${e.key}: ${e.value}').join('; '))}"');
      }
      if (data.attributes != null && data.attributes!.isNotEmpty) {
        for (var attr in data.attributes!.entries) {
          _domValidator.validateAttributeName(attr.key);
          output.write(' ${attr.key}="${_attributeEscape.convert(attr.value)}"');
        }
      }
      var selfClosing = _domValidator.isSelfClosing(tag);
      if (selfClosing) {
        output.write('/>');
      } else {
        output.write('>');
        for (var child in data.children) {
          output.write(renderNodeHtml(child, kDebugMode ? inset + 2 : inset));
        }
        if (kDebugMode && data.children.isNotEmpty) {
          output.write(insetStr);
        }
        output.write('</$tag>');
      }
      return output.toString();
    } else {
      assert(element == root);
      var output = StringBuffer();
      for (var child in data.children) {
        output.write(renderNodeHtml(child, kDebugMode ? inset + 2 : inset));
      }
      return output.toString();
    }
  }

  final _attributeEscape = HtmlEscape(HtmlEscapeMode.attribute);
  final _domValidator = DomValidator();

}

/// DOM validator with sane defaults.
class DomValidator {
  static final _attributeRegExp = RegExp(r'^[a-z](?:[a-z0-9\-\_]*[a-z0-9]+)?$');
  static final _elementRegExp = _attributeRegExp;
  static const _selfClosing = <String>{
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'path',
    'source',
    'track',
    'wbr',
  };
  final _tags = <String>{};
  final _attrs = <String>{};

  void validateElementName(String tag) {
    if (_tags.contains(tag)) return;
    if (_elementRegExp.matchAsPrefix(tag) != null) {
      _tags.add(tag);
    } else {
      throw ArgumentError('"$tag" is not a valid element name.');
    }
  }

  void validateAttributeName(String name) {
    if (_attrs.contains(name)) return;
    if (_attributeRegExp.matchAsPrefix(name) != null) {
      _attrs.add(name);
    } else {
      throw ArgumentError('"$name" is not a valid attribute name.');
    }
  }

  bool isSelfClosing(String tag) {
    return _selfClosing.contains(tag);
  }
}
