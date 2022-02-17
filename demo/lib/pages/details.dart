import 'package:jaspr/jaspr.dart';

import '../components/book.dart';
import '../services/service.dart';

class Details extends StatefulComponent {
  Details(this.id) : super(key: GlobalObjectKey('book-$id'));

  final String id;

  @override
  State<StatefulComponent> createState() => DetailsState();
}

class DetailsState extends State<Details>
    with PreloadStateMixin<Details>, SyncStateMixin<Details, Map<String, dynamic>> {
  late Map<String, dynamic> book;

  @override
  Future<void> preloadState() async {
    book = await BooksService.instance!.getBookById(component.id);
  }

  @override
  Map<String, dynamic> saveState() {
    return book;
  }

  @override
  String get syncId => 'book-${component.id}';

  @override
  void updateState(Map<String, dynamic>? value) {
    setState(() {
      book = value ?? {};
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield BookInfo(book: book);

    yield DomComponent(tag: 'div', classes: [
      'book-details'
    ], children: [
      DomComponent(
        tag: 'p',
        child: Text('Genre: ${book['genre']}'),
      ),
      DomComponent(
        tag: 'p',
        child: Text('Publisher: ${book['publisher']}'),
      ),
      DomComponent(
        tag: 'p',
        classes: ['book-description'],
        child: Text(book['description'] ?? ''),
      ),
    ]);
  }
}
