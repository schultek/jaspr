// example service

abstract class BooksService {
  // better to use a service locator, this is just for demo purposes
  static BooksService? instance;

  Future<Map<String, dynamic>> getBookById(String id);
  Future<List<dynamic>> getBooks();
}
