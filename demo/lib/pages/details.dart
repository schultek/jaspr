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
  late Book book;

  @override
  Future<Map<String, dynamic>> preloadState() {
    return BooksService.instance!.getBookById(component.id).then((book) => book.toMap());
  }

  @override
  void didLoadState() {
    initState();
  }

  @override
  void initState() {
    super.initState();
    book = preloadedState != null ? Book.fromMap(preloadedState!) : Book('', '');
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield BookInfo(book: book);
  }
}
