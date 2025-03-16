import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:watcher/watcher.dart';

import '../page.dart';
import 'data_loader.dart';

/// A data loader that loads data from the filesystem.
class FilesystemDataLoader implements DataLoader {
  FilesystemDataLoader(this.directory);

  final String directory;

  StreamSubscription<WatchEvent>? _watcherSub;
  StreamSubscription? _reassembleSub;
  Future<Map<String, dynamic>>? _data;

  @override
  Future<void> loadData(Page page) async {
    _watcherSub ??= DirectoryWatcher(directory).events.listen((event) {
      _data = null;
      page.markNeedsRebuild();
      _watcherSub?.cancel();
      _watcherSub = null;
    });

    _reassembleSub ??= ServerApp.onReassemble.listen((_) {
      _data = null;
      _watcherSub?.cancel();
      _watcherSub = null;
      _reassembleSub?.cancel();
      _reassembleSub = null;
    });

    _data ??= _loadData(Directory(directory));
    page.apply(data: await _data);
  }

  Future<Map<String, dynamic>> _loadData(Directory dir) async {
    final data = <String, dynamic>{};
    if (await dir.exists()) {
      await for (var entity in dir.list()) {
        if (entity is File) {
          final name = entity.path.split('/').last;
          final key = name.split('.').first;
          data[key] = DataLoader.parseData(name, await entity.readAsString());
        } else if (entity is Directory) {
          final key = entity.path.split('/').last;
          data[key] = await _loadData(entity);
        }
      }
    }
    return data;
  }
}
