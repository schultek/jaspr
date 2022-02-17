import 'package:jaspr/jaspr.dart';
import 'package:jaspr_demo/components/book.dart';
import 'package:jaspr_demo/services/service.dart';

class Home extends StatefulComponent {
  Home() : super(key: GlobalObjectKey('books'));

  @override
  State<StatefulComponent> createState() => HomeState();
}

class HomeState extends State<Home> with PreloadStateMixin<Home>, SyncStateMixin<Home, List> {
  late List books;

  @override
  Future<void> preloadState() async {
    books = await BooksService.instance!.getBooks();
  }

  @override
  List saveState() {
    return books;
  }

  @override
  String get syncId => 'books';

  @override
  void updateState(List? value) {
    print("UPDATE $value");
    setState(() {
      books = value ?? [];
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'div', classes: [
      'books-list'
    ], children: [
      for (var book in books)
        DomComponent(
          tag: 'div',
          events: {
            'click': () => Router.of(context).push('/book/${book['id']}'),
            'mouseenter': () => Router.of(context).preload('/book/${book['id']}'),
          },
          child: BookInfo(book: book),
        ),
    ]);
  }
}
