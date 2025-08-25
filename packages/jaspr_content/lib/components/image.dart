import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import '_internal/zoomable_image.dart';

/// An image component with optional zooming and caption support.
class Image implements CustomComponent {
  const Image({
    this.zoom = false,
    this.replaceImg = true,
  });

  static Component from({
    required String src,
    String? alt,
    String? caption,
    bool zoom = false,
    Key? key,
  }) {
    if (zoom) {
      return ZoomableImage(src: src, alt: alt, caption: caption, key: key);
    }
    return _Image(src: src, alt: alt, caption: caption, key: key);
  }

  /// Whether to enable zooming on the image.
  final bool zoom;

  /// Whether to replace the default <img> tag with this component.
  final bool replaceImg;

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node
        case ElementNode(tag: 'img' || 'Image', :final attributes) ||
            ElementNode(tag: 'p', children: [ElementNode(tag: 'img' || 'Image', :final attributes)])) {
      assert(attributes.containsKey('src'), 'Image must have a "src" argument. Found $attributes');
      return from(
        src: attributes['src']!,
        alt: attributes['alt'],
        caption: attributes['caption'],
        zoom: zoom || attributes['zoom'] != null,
      );
    }
    return null;
  }

  @css
  static List<StyleRule> get styles => [
        css('figure.image', [
          css('&').styles(
            display: Display.flex,
            flexDirection: FlexDirection.column,
            alignItems: AlignItems.center,
          ),
        ]),
      ];
}

/// An image component with an optional caption.
class _Image extends StatelessComponent {
  const _Image({
    required this.src,
    this.alt,
    this.caption,
    super.key,
  });

  /// The image source URL.
  final String src;

  /// The image alt text.
  final String? alt;

  /// The image caption.
  final String? caption;

  @override
  Component build(BuildContext context) {
    return figure(classes: 'image', [
      img(src: src, alt: alt ?? caption),
      if (caption != null) figcaption([text(caption!)]),
    ]);
  }
}
