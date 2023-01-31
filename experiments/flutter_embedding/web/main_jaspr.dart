import 'package:element_embedding_demo/components/demo_controls.dart';
import 'package:element_embedding_demo/interop/flutter.dart';
import 'package:jaspr/browser.dart';

void main() {
  runApp(DemoControls(), attachTo: '#demo_controls');
  runFlutterApp(attachTo: '#flutter_target');
}
