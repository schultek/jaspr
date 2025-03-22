import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import '_internal/zoomable_image.dart';

class ImageExtension implements PageExtension {
  const ImageExtension({
    this.zoom = false,
  });

  final bool zoom;

  @override
  List<Node> apply(Page page, List<Node> nodes) {
    final processed = <Node>[];
    for (final node in nodes) {
      if (node case ElementNode(tag: 'img' || 'Image', :final attributes)) {
        processed.add(ComponentNode(Image._fromAttributes(attributes, zoom)));
        continue;
      }
      if (node case ElementNode(tag: 'p', children: [ElementNode(tag: 'img' || 'Image', :final attributes)])) {
        processed.add(ComponentNode(Image._fromAttributes(attributes, zoom)));
        continue;
      }

      processed.add(node);
    }
    return processed;
  }
}

/// An image component with an optional caption.
class Image extends StatelessComponent {
  const Image({
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

  static ComponentFactory factory = ComponentFactory(
    pattern: 'Image',
    build: (_, attrs, ___) => _fromAttributes(attrs, false),
  );

  static Component _fromAttributes(Map<String, String> attributes, bool globalZoom) {
    assert(attributes.containsKey('src'), 'Image must have a "src" argument. Found $attributes');
    final zoomable = globalZoom || attributes['zoom'] != null;
    if (zoomable) {
      return ZoomableImage(
        src: attributes['src']!,
        alt: attributes['alt'],
        caption: attributes['caption'],
      );
    }

    return Image(
      src: attributes['src']!,
      alt: attributes['alt'],
      caption: attributes['caption'],
    );
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'figure', classes: 'image', children: [
      img(src: src, alt: alt ?? caption),
      if (caption != null) DomComponent(tag: 'figcaption', children: [text(caption!)]),
    ]);
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
