import 'package:jaspr/jaspr.dart';

import '../services/service.dart';

class Image extends StatefulComponent {
  Image(this.id) : super();

  final String id;

  @override
  State<StatefulComponent> createState() => ImageState();
}

class ImageState extends State<Image> with PreloadStateMixin, SyncStateMixin<Image, Map<String, dynamic>> {
  late Map<String, dynamic> image;

  @override
  Future<void> preloadState() async {
    image = await ImageService.instance!.getImageById(component.id);
  }

  @override
  Map<String, dynamic> getState() {
    return image;
  }

  @override
  String get syncId => 'image-${component.id}';

  @override
  void updateState(Map<String, dynamic>? value) {
    setState(() {
      image = value ?? {};
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'img',
      attributes: {'src': image['download_url'] ?? '', 'preload': ''},
    );
  }
}
