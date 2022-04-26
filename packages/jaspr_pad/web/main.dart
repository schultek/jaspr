import 'package:jaspr/jaspr.dart';
import 'package:jaspr_pad/app.dart';
import 'package:jaspr_pad/providers/samples_provider.dart';

void main() {
  runApp(
      () => App(providerOverrides: [
            samplesProvider.overrideWithProvider(syncSamplesProvider),
          ]),
      id: 'playground');
}
