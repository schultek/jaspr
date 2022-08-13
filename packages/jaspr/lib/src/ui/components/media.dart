import 'package:jaspr/jaspr.dart';
import 'package:jaspr/src/ui/components/base.dart';

class Image extends BaseComponent {
  final double width;
  final double height;
  final Uri source;
  final String? description;
  final String? tooltip;
  final bool lazyLoading;

  const Image({
    required this.source,
    this.width = 320,
    this.height = 240,
    this.description,
    this.tooltip,
    this.lazyLoading = false,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
    super.children,
  }) : super(tag: 'img');

  @override
  Map<String, String> getAttributes() => {
    'width': width.toString(),
    'height': height.toString(),
    'src': source.toString(),
    if (description != null) 'alt': description!,
    if (tooltip != null) 'title': tooltip!,
    if (lazyLoading) 'loading': 'lazy',
    ...super.attributes ?? {},
  };
}

class Video extends BaseComponent {
  final double width;
  final double height;
  final Uri source;
  final String defaultText;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final Uri? poster;

  const Video({
    required this.source,
    this.width = 320,
    this.height = 240,
    this.defaultText = 'Video cannot be played.',
    this.showControls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.poster,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'video');


  @override
  List<Component> getChildren() => [Text(defaultText)];

  @override
  Map<String, String> getAttributes() => {
    'width': width.toString(),
    'height': height.toString(),
    'src': source.toString(),
    if (showControls) 'controls': '',
    if (autoplay) 'autoplay': '',
    if (loop) 'loop': '',
    if (muted) 'muted': '',
    if (poster != null) 'poster': poster.toString(),
      ...super.attributes ?? {},
  };
}

class Audio extends BaseComponent {
  final Uri source;
  final String defaultText;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;

  const Audio({
    required this.source,
    this.defaultText = 'Audio cannot be played.',
    this.showControls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'audio');


  @override
  List<Component> getChildren() => [Text(defaultText)];

  @override
  Map<String, String> getAttributes() => {
    'src': source.toString(),
    if (showControls) 'controls': '',
    if (autoplay) 'autoplay': '',
    if (loop) 'loop': '',
    if (muted) 'muted': '',
    ...super.attributes ?? {},
  };
}