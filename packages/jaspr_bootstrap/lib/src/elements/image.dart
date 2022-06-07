import 'package:jaspr/jaspr.dart';

class Image extends StatelessComponent {
  final String source;
  final String description;
  final int width;
  final int height;
  final List<String> classes;

  Image({this.width = 100, this.height = 100, required this.source, this.description = "kfdls", this.classes = const []});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'img',
      //styles: {'width': '$width%', 'height': '$height%'},
      classes: [...classes],
      attributes: {'src': source, 'alt': description},
    );
  }
}
