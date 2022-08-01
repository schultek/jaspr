import 'package:jaspr/jaspr.dart';
import './app.dart';
import 'mobx_hooks/mobx_hooks.dart';

void main() {
  runApp(const MobXHooksObserverComponent(child: App()));
}
