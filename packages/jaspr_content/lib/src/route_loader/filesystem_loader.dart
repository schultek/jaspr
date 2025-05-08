import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:watcher/watcher.dart';

import '../page.dart';
import 'route_loader.dart';

/// A loader that loads routes from the filesystem.
///
/// Routes are constructed based on the recursive folder structure under the root [directory].
/// Index files (index.*) are treated as the page for the containing folder.
/// Files and folders starting with an underscore (_) are ignored.
class FilesystemLoader extends RouteLoaderBase {
  FilesystemLoader(
    this.directory, {
    this.keeySuffixPattern,
    super.debugPrint,
  });

  /// The directory to load pages from.
  final String directory;

  /// A pattern to keep the file suffix for all matching pages.
  final Pattern? keeySuffixPattern;

  final Map<String, Set<String>> dependentPages = {};

  StreamSubscription<WatchEvent>? _watcherSub;

  @override
  String getKeyForRoute(PageRoute route) {
    return route.source;
  }

  @override
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver, bool eager) async {
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
    return super.loadRoutes(resolver, eager);
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
  Future<List<RouteEntity>> loadPageEntities() async {
    final dir = Directory(directory);

    List<RouteEntity> loadEntities(Directory dir) {
      List<RouteEntity> entities = [];
      for (final entry in dir.listSync()) {
        final name = entry.path.substring(dir.path.length + 1);
        if (entry is File) {
          entities.add(SourceRoute(name, entry.path, keepSuffix: keeySuffixPattern?.matchAsPrefix(entry.path) != null));
        } else if (entry is Directory) {
          entities.add(CollectionRoute(name, loadEntities(entry)));
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

    return Page(
      path: route.path,
      url: route.url,
      content: content,
      data: {},
      config: config,
      loader: loader,
    );
  }
}
