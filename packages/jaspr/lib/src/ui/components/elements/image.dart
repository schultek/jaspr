import 'package:jaspr/components.dart';

class Image extends Box {
  final String source;
  final String alternate;

  const Image({
    required this.source,
    this.alternate = '',
    super.key,
    super.id,
    super.style,
    super.classes,
    super.attributes,
    super.events,
  }) : super(tag: 'img');

  @override
  Map<String, String> getAttributes() {
    return {
      'src': source,
      'alt': alternate,
      ...super.getAttributes(),
    };
  }

}
