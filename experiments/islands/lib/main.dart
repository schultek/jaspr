import 'package:jaspr/islands.dart';
import 'package:jaspr/jaspr.dart';

import 'components/app.dart';

void main() {
  var numCounters = 3;

  runApp(IslandsApp(
    child: App(numCounters),
  ));
}
