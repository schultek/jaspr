import 'package:jaspr/jaspr.dart';

mixin TrackStateLifecycle<T extends StatefulComponent> on State<T> {
  List<String> lifecycle = [];

  @override
  void didUpdateComponent(covariant T oldComponent) {
    super.didUpdateComponent(oldComponent);
    lifecycle.add('didUpdateComponent');
  }

  @override
  void initState() {
    super.initState();
    lifecycle.add('initState');
  }

  @override
  void deactivate() {
    lifecycle.add('deactivate');
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    lifecycle.add('activate');
  }

  @override
  void didChangeDependencies() {
    lifecycle.add('didChangeDependencies');
    super.didChangeDependencies();
  }

  void trackBuild() {
    lifecycle.add('build');
  }

  @override
  void dispose() {
    lifecycle.add('dispose');
    super.dispose();
  }
}
