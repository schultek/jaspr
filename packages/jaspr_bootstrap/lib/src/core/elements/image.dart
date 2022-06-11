import 'package:jaspr/jaspr.dart';

class Image extends StatelessComponent {
  final String source;
  final String alternate;
  final int width;
  final int height;
  final Iterable<String>? classes;

  Image({this.width = 100, this.height = 100, required this.source, this.alternate = '', this.classes});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'img',
      classes: classes,
      attributes: {'src': source, 'alt': alternate},
    );
  }
}
