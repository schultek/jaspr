import 'package:jaspr/jaspr.dart';
import 'package:jaspr_demo/components/book.dart';

import 'app.dart';
import 'services/service.dart';

class ServerBooksService implements BooksService {
  final books = <String, Book>{
    '0': Book('Left Hand of Darkness', 'Ursula K. Le Guin'),
    '1': Book('Too Like the Lightning', 'Ada Palmer'),
    '2': Book('Kindred', 'Octavia E. Butler'),
  };

  @override
  Future<Book> getBookById(String id) async => books[id] ?? Book('', '');

  @override
  Future<Map<String, Book>> getBooks() async => books;
}

void main() {
  runApp(() {
    // create a service instance
    BooksService.instance = ServerBooksService();

    // provide an entry component and an id to attach it to
    return App();
  }, id: 'app');
}
