import 'package:jaspr/server.dart';
import 'package:jaspr_og/jaspr_og.dart';

import '../page.dart';
import 'secondary_output.dart';

/// Outputs a secondary 'social.png' image for a page.
///
/// This is used for generating dynamic OpenGraph images (social cards) for pages.
/// The image is generated from a Jaspr svg component.
class SecondaryImageOutput extends SecondaryOutput {
  SecondaryImageOutput({ this.width = 1200, this.height = 630,
    required this.builder});

  final int width;
  final int height;
  final Component Function(Page) builder;

  @override
  final Pattern pattern = RegExp(r'.*');

  @override
  String createRoute(String route) {
    if (route.endsWith('/')) {
      route += 'social';
    } else if (!route.split('/').last.contains('.')) {
      route += '/social';
    }
    return route += '.png';
  }

  @override
  Component build(Page page) {
    return AsyncBuilder(builder: (context) async* {
      final output = await renderSvg(builder(page), width: width, height: height);
      context.setHeader('Content-Type', 'image/png');
      context.setStatusCode(200, responseBytes: output);
    });
  }
}
