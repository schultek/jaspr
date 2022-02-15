import 'package:domino/domino.dart' hide DomComponent;
import 'package:jaspr/jaspr.dart';

class PreloadImages extends StatefulComponent {
  PreloadImages({required this.child}) : super(key: StateKey(id: 'preload-images'));

  final Component child;

  @override
  State<StatefulComponent> createState() => PreloadImagesState();

  @override
  Element createElement() => PreloadImagesElement(this);
}

class PreloadImagesState extends State<PreloadImages> with PreloadStateMixin<PreloadImages, List> {
  Set<String> preloadImages = {};

  @override
  Future<List> preloadState() async {
    return [];
  }

  @override
  void initState() {
    super.initState();
    preloadImages.addAll(preloadedState?.cast<String>() ?? []);
  }

  @override
  void didLoadState() {
    super.didLoadState();
    preloadImages.addAll(preloadedState?.cast<String>() ?? []);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield component.child;

    if (kIsWeb) {
      for (var image in preloadImages) {
        yield DomComponent(
          tag: 'link',
          attributes: {'rel': 'preload', 'as': 'image', 'href': image},
          events: {
            'onload': () {
              print("LOADED");
              preloadImages.remove(image);
              setState(() {});
            }
          },
        );
      }
    }
  }

  void _addPreloadImage(String s) {
    preloadedState?.add(s);
  }
}

class PreloadImagesElement extends StatefulElement {
  PreloadImagesElement(PreloadImages component) : super(component);

  @override
  void render(DomBuilder b) {
    if (!kIsWeb) {
      super.render(PreloadImagesDomBuilder(b, state as PreloadImagesState));
    } else {
      super.render(b);
    }
  }
}

class PreloadImagesDomBuilder extends DomBuilder {
  PreloadImagesDomBuilder(this.builder, this.state);

  final DomBuilder builder;
  final PreloadImagesState state;

  @override
  void open(String tag,
      {String? key,
      String? id,
      Iterable<String>? classes,
      Map<String, String>? styles,
      Map<String, String>? attributes,
      Map<String, DomEventFn>? events,
      DomLifecycleEventFn? onCreate,
      DomLifecycleEventFn? onUpdate,
      DomLifecycleEventFn? onRemove}) {
    builder.open(tag,
        key: key,
        id: id,
        classes: classes,
        styles: styles,
        attributes: attributes,
        events: events,
        onCreate: onCreate,
        onUpdate: onUpdate,
        onRemove: onRemove);

    if (tag == 'img' && attributes?['preload'] != null && attributes?['src'] != null) {
      state._addPreloadImage(attributes!['src']!);
    }
  }

  @override
  void close({String? tag}) => builder.close(tag: tag);

  @override
  void innerHtml(String value) => builder.innerHtml(value);

  @override
  void skipNode() => builder.skipNode();

  @override
  void skipRemainingNodes() => builder.skipRemainingNodes();

  @override
  void text(String value) => builder.text(value);
}
