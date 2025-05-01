import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:jaspr/server.dart';
import 'package:nanoid/non_secure.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:shelf/src/headers.dart';
import 'package:xml/xml.dart';

import 'src/render.dart';
import 'src/resvg.dart' as resvg;
export 'src/render.dart' show RenderError;

Future<Uint8List> renderSvg(Component child, {required int width, required int height}) async {
  final stopwatch = Stopwatch()..start();

  var binding =
      ServerAppBinding((url: '/', headers: Headers.empty()), loadFile: (_) => Future.value(null))
        ..initializeOptions(JasprOptions())
        ..attachRootComponent(child);
  final body = await binding.render(standalone: true);
  final content = switch (body) {
    ResponseBodyString() => body.content,
    ResponseBodyBytes() => utf8.decode(body.bytes),
  };

  print("Jaspr render took: ${stopwatch.elapsedMilliseconds}ms");
  stopwatch.reset();

  final processor = TreeProcessor(content);
  processor.processAlignElements();
  final svg = processor.document.toXmlString(pretty: true, indent: '  ');

  print("Processing took: ${stopwatch.elapsedMilliseconds}ms");
  stopwatch.reset();

  try {
    return render(svg, width: width, height: height);
  } finally {
    print("Render took: ${stopwatch.elapsedMilliseconds}ms");
    stopwatch.stop();
  }
}

class TreeProcessor {
  TreeProcessor(String svg) {
    document = XmlDocument.parse(svg);
    measurement = TreeMeasurement(svg);
  }

  late final XmlDocument document;
  late final TreeMeasurement measurement;

  void processAlignElements() {
    final targets = <(XmlElement, Alignment)>[];

    for (final element in document.descendantElements) {
      if (element.getAttribute('align') case final align?) {
        final parent = element.parentElement;
        if (parent == null) {
          print('Element without parent: ${element.toXmlString()}');
          continue;
        }

        element.removeAttribute('align');

        element.ensureId();
        if (parent != document.rootElement) {
          parent.ensureId();
        }

        targets.add((element, Alignment.fromString(align)));
      }
    }

    final measurement = TreeMeasurement(document.toXmlString());

    for (final (element, alignment) in targets) {
      final id = element.getAttribute('id')!;
      final bbox = measurement.getBoundingBox(id);

      double? parentAlignX;
      double? parentAlignY;

      if (element.parentElement == document.rootElement) {
        final size = measurement.getSize();
        parentAlignX = alignment.x != null ? size.width * alignment.x! : 0;
        parentAlignY = alignment.y != null ? size.height * alignment.y! : 0;
      } else {
        final parentId = element.parentElement!.getAttribute('id')!;
        final parentBbox = measurement.getBoundingBox(parentId);
        parentAlignX = alignment.x != null ? parentBbox.x + (parentBbox.width * alignment.x!) : 0;
        parentAlignY = alignment.y != null ? parentBbox.y + (parentBbox.height * alignment.y!) : 0;
      }

      final alignX = alignment.x != null ? bbox.x + (bbox.width * alignment.x!) : 0;
      final alignY = alignment.y != null ? bbox.y + (bbox.height * alignment.y!) : 0;

      final offsetX = parentAlignX - alignX;
      final offsetY = parentAlignY - alignY;

      final wrapped = XmlElement(
        XmlName.fromString('g'),
        [XmlAttribute(XmlName.fromString('transform'), 'translate($offsetX, $offsetY)')],
        [],
        false,
      );

      element.replace(wrapped);
      wrapped.children.add(element);
    }

    measurement.dispose();
  }

  String printBbox(resvg.rect bbox) {
    return '(${bbox.x}, ${bbox.y}, ${bbox.width}, ${bbox.height})';
  }
}

extension on XmlElement {
  void ensureId() {
    final id = getAttribute('id');
    if (id == null) {
      final newId = nanoid();
      setAttribute('id', newId);
    }
  }
}

class TreeMeasurement {
  TreeMeasurement(String svg) {
    tree = createTree(svg);
  }

  late final Pointer<resvg.render_tree> tree;

  resvg.size getSize() {
    return resvg.get_image_size(tree);
  }

  resvg.rect getBoundingBox(String nodeId) {
    final bbox = malloc<resvg.rect>();
    resvg.get_node_bbox(tree, nodeId.toNativeUtf8().cast(), bbox);
    return bbox.ref;
  }

  void dispose() {
    resvg.tree_destroy(tree);
  }
}

class Alignment {
  const Alignment(this.x, this.y);

  final double? x;
  final double? y;

  static Alignment fromString(String value) {
    final match = RegExp(r'^(center|top|bottom|left|right)$|^(top|center|bottom|none)\s+(left|center|right|none)$').firstMatch(value);
    if (match == null) {
      throw ArgumentError('Invalid alignment value: $value');
    }

    if (match.group(1) != null) {
      return switch (match.group(1)) {
        'center' => Alignment(0.5, 0.5),
        'left' => Alignment(0.0, null),
        'right' => Alignment(1.0, null),
        'top' => Alignment(null, 0.0),
        'bottom' => Alignment(null, 1.0),
        _ => throw ArgumentError('Invalid alignment: ${match.group(1)}'),
      };
    }

    return Alignment(
      switch (match.group(3)) {
        'left' => 0.0,
        'center' => 0.5,
        'right' => 1.0,
        'none' => null,
        _ => throw ArgumentError('Invalid horizontal alignment: ${match.group(3)}'),
      },
      switch (match.group(2)) {
        'top' => 0.0,
        'center' => 0.5,
        'bottom' => 1.0,
        'none' => null,
        _ => throw ArgumentError('Invalid vertical alignment: ${match.group(2)}'),
      },
    );
  }
}
