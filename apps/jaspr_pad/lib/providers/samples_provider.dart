import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../models/sample.dart';
import 'utils.dart';

final syncSamplesProvider = SyncProvider<List<Sample>>((ref) {
  return [];
}, id: 'samples', codec: MapperCodec());
