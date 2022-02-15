import 'package:jaspr/jaspr.dart';

class BookInfo extends StatelessComponent {
  BookInfo({required this.book});

  final Map<String, dynamic> book;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['book-info'],
      children: [
        DomComponent(tag: 'span', classes: ['book-title'], child: Text(book['title'] ?? '')),
        DomComponent(tag: 'span', classes: ['book-author'], child: Text(book['author'] ?? '')),
      ],
    );
  }
}
