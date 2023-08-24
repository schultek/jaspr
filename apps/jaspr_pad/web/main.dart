import 'package:jaspr/browser.dart';
import 'package:jaspr_pad/components/playground/playground.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

void main() {
  runApp(ProviderScope(
    child: Playground(),
  ));
}
