import 'package:jaspr/jaspr.dart';

import '../services/service.dart';

class Image extends StatefulComponent {
  Image(this.id) : super(key: StateKey(id: 'image-$id'));

  final String id;

  @override
  State<StatefulComponent> createState() => ImageState();
}

class ImageState extends State<Image> with PreloadStateMixin<Image, Map<String, dynamic>> {
  late Map<String, dynamic> image;

  @override
  Future<Map<String, dynamic>> preloadState() {
    return ImageService.instance!.getImageById(component.id);
  }

  @override
  void didLoadState() {
    initState();
  }

  @override
  void initState() {
    super.initState();
    image = preloadedState ?? {};
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'img',
      attributes: {'src': image['download_url'] ?? '', 'preload': ''},
    );
  }
}
