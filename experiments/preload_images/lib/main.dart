import 'dart:convert';

import 'package:http/http.dart';
import 'package:jaspr/server.dart';

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
  runServer(Builder.single(builder: (context) {
    // create a service instance
    ImageService.instance = ServerImageService();
    return App();
  }));
}
