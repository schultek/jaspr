import 'package:jaspr/server.dart';
import './app.dart';
import 'mobx_hooks/jaspr_observer.dart';

void main() {
  runApp(const MobXHooksObserverComponent(child: App()));
}
