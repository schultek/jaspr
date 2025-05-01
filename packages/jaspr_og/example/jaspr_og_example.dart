import 'dart:io';

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_og/jaspr_og.dart';

void main() async {
  final image = await renderSvg(svg([]), width: 1200, height: 630);

  File('image.png').writeAsBytesSync(image);
}
