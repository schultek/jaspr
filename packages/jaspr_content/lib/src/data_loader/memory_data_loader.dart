import 'dart:async';

import '../page.dart';
import 'data_loader.dart';

/// A data loader that loads data from memory.
class MemoryDataLoader implements DataLoader {
  const MemoryDataLoader(this.data);

  final Map<String, dynamic> data;

  @override
  Future<void> loadData(Page page) async {
    page.apply(data: data);
  }
}
