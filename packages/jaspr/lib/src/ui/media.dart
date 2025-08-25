import '../../jaspr.dart';

class Image extends StatelessComponent {
  const Image({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.description,
    this.tooltip,
    this.lazyLoading = false,
  });

  final int? width;
  final int? height;
  final Uri source;
  final String? description;
  final String? tooltip;
  final bool lazyLoading;

  @override
  Component build(BuildContext context) {
    return img(src: source.toString(), width: width, height: height, alt: description, attributes: {
      if (tooltip != null) 'title': tooltip!,
      if (lazyLoading) 'loading': 'lazy',
    });
  }
}

class Video extends StatelessComponent {
  const Video({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.defaultText = 'Video cannot be played.',
    this.showControls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.poster,
  });

  final Uri source;
  final int? width;
  final int? height;
  final String? defaultText;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final Uri? poster;

  @override
  Component build(BuildContext context) {
    return video(
      src: source.toString(),
      width: width,
      height: height,
      autoplay: autoplay,
      loop: loop,
      muted: muted,
      controls: showControls,
      poster: poster?.toString(),
      [if (defaultText != null) text(defaultText!)],
    );
  }
}

class Audio extends StatelessComponent {
  const Audio({
    super.key,
    required this.source,
    this.defaultText = 'Audio cannot be played.',
    this.showControls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
  });

  final Uri source;
  final String? defaultText;
  final bool showControls;
  final bool autoplay;
  final bool loop;
  final bool muted;

  @override
  Component build(BuildContext context) {
    return audio(
      src: source.toString(),
      autoplay: autoplay,
      loop: loop,
      muted: muted,
      controls: showControls,
      [if (defaultText != null) text(defaultText!)],
    );
  }
}
