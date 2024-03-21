import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../services/service.dart';

class Home extends StatefulComponent {
  Home({super.key});

  @override
  State<StatefulComponent> createState() => HomeState();
}

class HomeState extends State<Home> with PreloadStateMixin, SyncStateMixin<Home, List> {
  late List images;

  @override
  Future<void> preloadState() async {
    images = await ImageService.instance!.getImages();
  }

  @override
  List getState() {
    return images;
  }

  @override
  String get syncId => 'images';

  @override
  void updateState(List? value) {
    setState(() {
      images = value ?? [];
    });
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: 'images-list',
      children: [
        for (var image in images)
          DomComponent(
            tag: 'div',
            events: {
              'click': (e) => Router.of(context).push('/image/${image['id']}'),
              'mouseenter': (e) => Router.of(context).preload('/image/${image['id']}'),
            },
            child: Text('Image: ${image['id']} by ${image['author']}'),
          ),
      ],
    );
  }
}
