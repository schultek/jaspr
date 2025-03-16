import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:watcher/watcher.dart';

import '../page.dart';
import 'page_loader.dart';

/// A loader that loads pages from the filesystem.
/// 
/// Routes are constructed based on the recursive folder structure under the root [directory].
/// Index files (index.*) are treated as the page for the containing folder.
/// Files and folders starting with an underscore (_) are ignored.
class FilesystemLoader extends PageLoaderBase {
  FilesystemLoader(
    this.directory, {
    super.eager,
    super.debugPrint,
  });

  /// The directory to load pages from.
  final String directory;

  final Map<String, Set<String>> dependentPages = {};

  StreamSubscription<WatchEvent>? _watcherSub;

  @override
  String getKeyForRoute(PageRoute route) {
    return route.source;
  }

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver) async {
    if (kDebugMode) {
      _watcherSub ??= DirectoryWatcher(directory).events.listen((event) {
        var path = event.path;
        if (event.type == ChangeType.MODIFY) {
          invalidateKey(path);
        } else if (event.type == ChangeType.REMOVE) {
          invalidateKey(path, rebuild: false);
          invalidateRoutes();
        } else if (event.type == ChangeType.ADD) {
          invalidateRoutes();
        }
      });
    }
    return super.loadRoutes(resolver);
  }

  @override
  void onReassemble() {
    _watcherSub?.cancel();
    _watcherSub = null;
  }

  @override
  Future<String> readPartial(String path, Page page) {
    return _getPartial(path, page).readAsString();
  }

  @override
  String readPartialSync(String path, Page page) {
    return _getPartial(path, page).readAsStringSync();
  }

  File _getPartial(String path, Page page) {
    final pagePath = getKeyForPage(page);
    if (pagePath != null) {
      (dependentPages[path] ??= {}).add(pagePath);
    }
    return File(path);
  }

  @override
  PageFactory createFactory(PageRoute page, PageConfig config) {
    return FilePageFactory(page, config, this);
  }

  @override
  void invalidateKey(String key, {bool rebuild = true}) {
    super.invalidateKey(key, rebuild: rebuild);
    final dependencies = {...?dependentPages[key]};
    dependentPages[key]?.clear();
    for (var dpath in dependencies) {
      invalidateKey(dpath, rebuild: rebuild);
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
  FilePageFactory(super.route, super.config, super.loader);

  @override
  Future<Page> buildPage() async {
    final file = File(route.source);
    final content = await file.readAsString();
    final data = {
      'page': {'url': route.route},
    };
    return Page(route.name, route.route, content, data, config, loader);
  }
}
