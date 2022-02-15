import 'dart:convert';

import 'package:http/http.dart';
import 'package:jaspr/jaspr.dart';

import 'app.dart';
import 'services/service.dart';

class ServerBooksService implements BooksService {
  List? books;

  @override
  Future<Map<String, dynamic>> getBookById(String id) async {
    var data = (await _getBooks())[int.parse(id) - 1];
    data['image'] = 'https://picsum.photos/id/${data['id'] * 11}/120/160';
    return data;
  }

  @override
  Future<List<dynamic>> getBooks() async {
    var data = await _getBooks();
    return data.map((d) => {'id': d['id'], 'title': d['title'], 'author': d['author']}).toList();
  }

  Future<List> _getBooks() async {
    if (books != null) return books!;
    var res = await get(Uri.parse('https://fakerapi.it/api/v1/books?_quantity=20&_seed=1'));
    return books = jsonDecode(res.body)['data'];
  }
}

void main() {
  runApp(() {
    // create a service instance
    BooksService.instance = ServerBooksService();

    // provide an entry component and an id to attach it to
    return App();
  }, id: 'app');
}
