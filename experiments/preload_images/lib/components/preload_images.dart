import 'package:jaspr/jaspr.dart';

class PreloadImages extends StatefulComponent {
  PreloadImages({required this.child}) : super();

  final Component child;

  @override
  State<StatefulComponent> createState() => PreloadImagesState();
}

class PreloadImagesState extends State<PreloadImages> with SyncStateMixin<PreloadImages, List> {
  Set<String> preloadImages = {};

  @override
  List getState() {
    visitImages(Element e) {
      if (e is DomElement &&
          e.component.tag == 'img' &&
          e.component.attributes?['preload'] != null &&
          e.component.attributes?['src'] != null) {
        preloadImages.add(e.component.attributes!['src']!);
      }
      e.visitChildren(visitImages);
    }

    (context as Element).visitChildren(visitImages);
    return preloadImages.toList();
  }

  @override
  String get syncId => 'preload-images';

  @override
  void updateState(List? value) {
    setState(() {
      preloadImages.addAll(value?.cast() ?? []);
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield component.child;

    if (ComponentsBinding.instance!.isClient) {
      for (var image in preloadImages) {
        yield DomComponent(
          tag: 'link',
          attributes: {'rel': 'preload', 'as': 'image', 'href': image},
          events: {
            'onload': (e) {
              preloadImages.remove(image);
              setState(() {});
            }
          },
        );
      }
    }
  }
}
