import 'package:jaspr/jaspr.dart';
import 'package:jaspr/src/ui/components/base.dart';

class Video extends BaseElement {
  final double width;
  final double height;
  final String source;
  final String defaultText;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final String? poster;

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
      'src': source,
      if (showControls) 'controls': '',
      if (autoplay) 'autoplay': '',
      if (loop) 'loop': '',
      if (muted) 'muted': '',
      if (poster != null) 'poster': poster.toString(),
        ...super.attributes ?? {},
      };
}