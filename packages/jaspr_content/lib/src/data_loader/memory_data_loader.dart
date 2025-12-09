import 'dart:async';

import '../page.dart';
import 'data_loader.dart';

/// A data loader that loads data from memory.
class MemoryDataLoader implements DataLoader {
  const MemoryDataLoader(this.data);

  final Map<String, Object?> data;

  @override
  Future<void> loadData(Page page) async {
    final pageData = page.data.page;
    page.apply(data: data);
    page.apply(data: {'page': pageData});
  }
}
