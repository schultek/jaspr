import 'package:jaspr/jaspr.dart';

enum HeaderSize { h1, h2, h3, h4, h5, h6 }

class Header extends StatelessComponent {
  final String text;
  final HeaderSize size;

  Header(this.text, {this.size = HeaderSize.h3});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: size.name,
      child: Text(text),
    );
  }
}
