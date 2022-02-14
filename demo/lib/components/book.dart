import 'package:dart_web/dart_web.dart';

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);

  Map<String, dynamic> toMap() => {'title': title, 'author': author};

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(map['title'], map['author']);
  }
}

class BookInfo extends StatelessComponent {
  BookInfo({required this.book});

  final Book book;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['book-info'],
      children: [
        DomComponent(tag: 'span', classes: ['book-title'], child: Text(book.title)),
        DomComponent(tag: 'span', classes: ['book-author'], child: Text(book.author)),
      ],
    );
  }
}
