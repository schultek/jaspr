import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';
import 'package:riverpod_experiment/app.dart';

void main() {
  runApp(() => ProviderScope(child: App()), id: 'output');
}
