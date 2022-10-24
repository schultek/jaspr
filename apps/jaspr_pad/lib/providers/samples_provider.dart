import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../models/sample.dart';
import 'utils.dart';

final samplesProvider = Provider<List<Sample>>((ref) {
  throw UnimplementedError();
});

final syncSamplesProvider = Provider<List<Sample>>((ref) {
  return ref.onSync<List<Sample>>(
        id: 'samples',
        onUpdate: (samples) {
          ref.state = samples ?? ref.state;
        },
        onSave: () => ref.state,
        codec: MapperCodec(),
      ) ??
      [];
});
