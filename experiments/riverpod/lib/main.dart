import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import 'app.dart';

void main() async {
  runApp(() {
    return ProviderScope(child: App());
  }, id: 'output');
}
