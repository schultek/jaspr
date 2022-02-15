// example service

abstract class ImageService {
  // better to use a service locator, this is just for demo purposes
  static ImageService? instance;

  Future<Map<String, dynamic>> getImageById(String id);
  Future<List> getImages();
}
