import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:watcher/watcher.dart';

import '../page.dart';
import 'page_loader.dart';

class FilesystemLoader extends PageLoaderBase {
  FilesystemLoader(
    this.directory, {
    super.eager,
    super.debugPrint,
  });

  final String directory;

  final Map<String, Set<String>> dependentPages = {};

  static StreamSubscription<WatchEvent>? _watchEvents;

  @override
  String getKeyForRoute(PageRoute route) {
    return route.source;
  }

  @override
  void didInit() {
    if (kDebugMode) {
      _watchEvents?.cancel();
      _watchEvents = DirectoryWatcher(directory).events.listen((event) {
        var path = event.path;
        if (event.type == ChangeType.MODIFY) {
          invalidate(path);
        } else if (event.type == ChangeType.REMOVE) {
          invalidate(path, rebuild: false);
          reload();
        } else if (event.type == ChangeType.ADD) {
          reload();
        }
      });
    }
  }

  @override
  Future<String> readPartial(Uri uri, Page page) {
    return _getPartial(uri, page).readAsString();
  }

  @override
  String readPartialSync(Uri uri, Page page) {
    return _getPartial(uri, page).readAsStringSync();
  }

  File _getPartial(Uri uri, Page page) {
    final path = getKeyForPage(page);
    if (path != null) {
      (dependentPages[uri.toFilePath()] ??= {}).add(path);
    }
    return File.fromUri(uri);
  }

  @override
  PageFactory createFactory(PageRoute page) {
    return FilePageFactory(page, this);
  }

  @override
  void invalidate(String key, {bool rebuild = true}) {
    super.invalidate(key, rebuild: rebuild);
    final dependencies = {...?dependentPages[key]};
    dependentPages[key]?.clear();
    for (var dpath in dependencies) {
      invalidate(dpath, rebuild: rebuild);
    }
  }

  @override
  void invalidateAll() {
    super.invalidateAll();
    dependentPages.clear();
  }

  @override
  Future<List<PageEntity>> loadPageEntities() async {
    final dir = Directory(directory);

    List<PageEntity> loadEntities(Directory dir) {
      List<PageEntity> entities = [];
      for (final entry in dir.listSync()) {
        final name = entry.path.substring(dir.path.length + 1);
        if (entry is File) {
          entities.add(PageSource(name, entry.path));
        } else if (entry is Directory) {
          entities.add(PageCollection(name, loadEntities(entry)));
        }
      }
      return entities;
    }

    return loadEntities(dir);
  }
}

class FilePageFactory extends PageFactory<FilesystemLoader> {
  FilePageFactory(super.route, super.loader);

  @override
  Future<Page> buildPage(PageConfig config) async {
    final file = File(route.source);
    final content = await file.readAsString();
    final data = {
      'page': {'url': route.route},
    };
    return Page(route.name, route.route, content, data, config, loader);
  }
}
