import 'package:jaspr/browser.dart';
import 'package:mypod_server/src/components/counter.dart';

void main() {
  runApp(Counter(), attachTo: '#counter');
}
