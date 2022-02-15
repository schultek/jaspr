import 'dart:convert';

import 'package:http/http.dart';
import 'package:jaspr/jaspr.dart';

import 'app.dart';
import 'services/service.dart';

class ServerImageService implements ImageService {
  List? images;

  @override
  Future<Map<String, dynamic>> getImageById(String id) async {
    var data = await _getImages();
    var img = data.firstWhere((i) => i['id'] == id);
    img['download_url'] = 'https://picsum.photos/id/$id/120/160';
    return img;
  }

  @override
  Future<List> getImages() async {
    var data = await _getImages();
    return data.map((d) => {'id': d['id'], 'author': d['author']}).toList();
  }

  Future<List> _getImages() async {
    if (images != null) return images!;
    var res = await get(Uri.parse('https://picsum.photos/v2/list'));
    return images = jsonDecode(res.body);
  }
}

void main() {
  runApp(() {
    // create a service instance
    ImageService.instance = ServerImageService();

    // provide an entry component and an id to attach it to
    return App();
  }, id: 'app');
}
