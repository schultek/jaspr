import 'package:jaspr/jaspr.dart';

import '../services/service.dart';

class Home extends StatefulComponent {
  Home() : super(key: StateKey(id: 'books'));

  @override
  State<StatefulComponent> createState() => HomeState();
}

class HomeState extends State<Home> with PreloadStateMixin<Home, List> {
  late List images;

  @override
  Future<List> preloadState() {
    return ImageService.instance!.getImages();
  }

  @override
  void didLoadState() {
    initState();
  }

  @override
  void initState() {
    super.initState();
    images = preloadedState ?? [];
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['images-list'],
      children: [
        for (var image in images)
          DomComponent(
            tag: 'div',
            events: {
              'click': () => Router.of(context).push('/image/${image['id']}'),
              'mouseenter': () => Router.of(context).preload('/image/${image['id']}'),
            },
            child: Text('Image: ${image['id']} by ${image['author']}'),
          ),
      ],
    );
  }
}
