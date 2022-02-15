import 'package:jaspr/jaspr.dart';

import '../components/book.dart';
import '../services/service.dart';

class Details extends StatefulComponent {
  Details(this.id) : super(key: StateKey(id: 'book-$id'));

  final String id;

  @override
  State<StatefulComponent> createState() => DetailsState();
}

class DetailsState extends State<Details> with PreloadStateMixin<Details, Map<String, dynamic>> {
  late Map<String, dynamic> book;

  @override
  Future<Map<String, dynamic>> preloadState() {
    return BooksService.instance!.getBookById(component.id);
  }

  @override
  void didLoadState() {
    initState();
  }

  @override
  void initState() {
    super.initState();
    book = preloadedState ?? {};
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield BookInfo(book: book);

    yield DomComponent(tag: 'div', classes: [
      'book-details'
    ], children: [
      DomComponent(
        tag: 'img',
        classes: ['book-cover'],
        attributes: {'src': book['image'] ?? '', 'preload': ''},
      ),
      DomComponent(
        tag: 'p',
        classes: ['book-description'],
        child: Text(book['description'] ?? ''),
      ),
    ]);
  }
}
