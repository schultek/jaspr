import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:ffi/ffi.dart' as ffi;
import 'package:image/image.dart';

import 'resvg.dart' as resvg;

typedef RenderError = resvg.resvg_error;

Uint8List render(String svg, {required int width, required int height}) {
  final Pointer<resvg.render_tree> tree = createTree(svg);
  final resvg.transform transform = resvg.transform_identity();

  final size = width * height * 4;
  final Pointer<Uint8> pixmap = ffi.calloc<Uint8>(size);

  resvg.render(tree, transform, width, height, pixmap.cast());

  resvg.tree_destroy(tree);

  final image = Image.fromBytes(
    width: width,
    height: height,
    bytes: pixmap.asTypedList(size).buffer,
    order: ChannelOrder.rgba,
  );

  final output = encodePng(image);

  ffi.calloc.free(pixmap);

  return output;
}

Pointer<resvg.render_tree> createTree(String svg) {
  final units = utf8.encode(svg);

  final Pointer<Uint8> result = malloc<Uint8>(units.length) //
    ..asTypedList(units.length).setAll(0, units);

  final Pointer<resvg.options> options = resvg.options_create();
  resvg.options_load_system_fonts(options);
  resvg.options_set_dpi(options, 300);

  final Pointer<Pointer<resvg.render_tree>> tree = calloc<Uint8>().cast();

  final error = resvg.parse_tree_from_data(result, units.length, options, tree);

  resvg.options_destroy(options);
  malloc.free(result);

  if (error != 0) {
    throw resvg.resvg_error.fromValue(error);
  }

  return tree.value;
}

resvg.transform createTransform() {
  return Struct.create<resvg.transform>()
    ..a = 1.0
    ..b = 0.0
    ..c = 0.0
    ..d = 1.0
    ..e = 0.0
    ..f = 0.0;
}