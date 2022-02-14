import 'package:jaspr/jaspr.dart';
import 'package:jaspr_demo/components/book.dart';
import 'package:jaspr_demo/services/service.dart';

class Home extends StatefulComponent {
  Home() : super(key: StateKey(id: 'books'));

  @override
  State<StatefulComponent> createState() => HomeState();
}

class HomeState extends State<Home> with PreloadStateMixin<Home, Map<String, dynamic>> {
  late Map<String, Book> books;

  @override
  Future<Map<String, dynamic>> preloadState() {
    return BooksService.instance!.getBooks().then((books) => books.map((k, v) => MapEntry(k, v.toMap())));
  }

  @override
  void didLoadState() {
    initState();
  }

  @override
  void initState() {
    super.initState();
    books = preloadedState != null ? preloadedState!.map((k, v) => MapEntry(k, Book.fromMap(v))) : {};
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', classes: [
      'books-list'
    ], children: [
      for (var entry in books.entries)
        DomComponent(
          tag: 'div',
          events: {
            'click': () => Router.of(context).push('/book/${entry.key}'),
          },
          child: BookInfo(book: entry.value),
        ),
    ]);
  }
}
