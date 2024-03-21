import 'package:jaspr/browser.dart';
import 'package:mypod_server/counter.dart';

void main() {
  runApp(Counter(), attachTo: '#counter');
}
