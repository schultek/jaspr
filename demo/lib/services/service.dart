// example service
import '../components/book.dart';

abstract class BooksService {
  // better to use a service locator, this is just for demo purposes
  static BooksService? instance;

  Future<Book> getBookById(String id);
  Future<Map<String, Book>> getBooks();
}
