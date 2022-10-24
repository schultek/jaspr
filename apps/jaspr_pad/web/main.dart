import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/components/playground/playground.dart';
import 'package:jaspr_pad/providers/samples_provider.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

void main() {
  runApp(ProviderScope(
    overrides: [samplesProvider.overrideWithProvider(syncSamplesProvider)],
    child: Playground(),
  ));
}
