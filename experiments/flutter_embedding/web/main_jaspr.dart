import 'package:element_embedding_demo/components/app.dart';
import 'package:element_embedding_demo/interop/flutter.dart';
import 'package:jaspr/browser.dart';

void main() {
  runApp(App());
  runFlutterApp(attachTo: '#flutter_target');
}
