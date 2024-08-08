import 'package:jaspr/jaspr.dart';

extension type ColorCodec(Color value) implements Color {
  @decoder
  ColorCodec.decode(String c) : value = Color.hex(c);

  @encoder
  String encode() => value.value;
}
