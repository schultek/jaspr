import 'dart:async';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../page.dart';

typedef ConfigResolver = PageConfig Function(String);

abstract class PagesLoader {
  Future<List<RouteBase>> loadRoutes(ConfigResolver resolver);
  File access(Uri path, Page page);
}

sealed class PageEntity {
  PageEntity(this.name);

  final String name;
}

class PageSource extends PageEntity {
  PageSource(super.name, this.path, [this.url]);

  final String path;
  final String? url;
}

class PageCollection extends PageEntity {
  PageCollection(super.name, this.entities);

  final List<PageEntity> entities;
}

final indexRegex = RegExp(r'index\.[^/]*$');

extension PagesRepositoryExtension on PagesLoader {
  List<RouteBase> buildRoutes({
    required List<PageEntity> entities,
    required Component Function(PageSource) buildPage,
    bool debugPrint = false,
  }) {
    final routes = _buildRoutes(entities: entities, buildPage: buildPage);
    if (debugPrint) {
      _printRoutes(routes);
    }
    return routes;
  }

  List<RouteBase> _buildRoutes({
    required List<PageEntity> entities,
    required Component Function(PageSource) buildPage,
    String path = '',
    bool isTopLevel = true,
  }) {
    PageSource? indexFile;
    List<PageSource> files = [];
    List<PageCollection> subdirs = [];

    for (final entry in entities) {
      if (entry.name.startsWith('_')) continue;

      if (entry is PageSource) {
        final isIndex = indexRegex.hasMatch(entry.name);
        if (isIndex) {
          indexFile = entry;
        } else {
          files.add(entry);
        }
      } else if (entry is PageCollection) {
        subdirs.add(entry);
      }
    }

    List<RouteBase> routes = [];

    for (final file in files) {
      final child = buildPage(file);

      final route = Route(
        path: (isTopLevel ? '/' : '') +
            (indexFile != null || path.isEmpty ? '' : '$path/') +
            file.name.replaceFirst(RegExp(r'\..*'), ''),
        builder: (context, state) => child,
      );
      routes.add(route);
    }

    for (final subdir in subdirs) {
      final subRoutes = _buildRoutes(
        entities: subdir.entities,
        buildPage: buildPage,
        path: (isTopLevel ? '/' : '') + (indexFile == null && path.isNotEmpty ? '$path/' : '') + subdir.name,
        isTopLevel: false,
      );
      routes.addAll(subRoutes);
    }

    if (indexFile != null) {
      final child = buildPage(indexFile);

      final route = Route(
        path: (isTopLevel ? '/' : '') + path,
        builder: (context, state) => child,
        routes: isTopLevel ? [] : routes,
      );

      if (isTopLevel) {
        routes.insert(0, route);
      } else {
        routes = [route];
      }
    }

    return routes;
  }

  void _printRoutes(List<RouteBase> routes, [String padding = '']) {
    for (final route in routes) {
      if (route is Route) {
        print('$padding${route.path}');
        _printRoutes(route.routes, '$padding  ');
      }
    }
  }
}
