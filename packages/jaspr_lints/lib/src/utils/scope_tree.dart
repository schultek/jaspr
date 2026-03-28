import 'dart:convert';
import 'dart:io' as io;

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:path/path.dart' as path;
import 'logging.dart';

class ScopeTree {
  ScopeTree();

  bool dirty = true;

  ScopeTreeNode analyzeLibrary(LibraryElement library) {
    final node = inspectLibrary(library);
    dirty |= node.dirty;
    node.analyzeChildren();

    return node;
  }

  Map<String, ScopeTreeNode> nodes = {};

  ScopeTreeNode inspectLibrary(LibraryElement library) {
    final path = library.firstFragment.source.fullName;

    if (library.isInSdk ||
        library.identifier.startsWith('package:jaspr/') ||
        library.identifier.startsWith('package:web/') ||
        library.identifier.startsWith('package:universal_web/') ||
        library.identifier.startsWith('package:flutter/')) {
      // Skip SDK and framework libraries.
      return nodes[path] ??= ScopeTreeNode(library, this);
    }

    if (nodes[path] case final node?) {
      if (node.library == library) {
        return node;
      }

      node.library = library;
      node.dirty = true;
      node.analyzeSelf();

      return node;
    }

    final node = ScopeTreeNode(library, this);
    nodes[path] = node;
    node.analyzeSelf();

    return node;
  }

  void writeScopes(String rootPath, {ResourceProvider? resourceProvider}) {
    late final scopesContent = jsonEncode(buildScopes());

    if (resourceProvider != null) {
      final scopesPath = resourceProvider.pathContext.join(rootPath, '.dart_tool', 'jaspr', 'scopes.json');
      final file = resourceProvider.getFile(scopesPath);
      if (!dirty && file.exists) return;

      file.writeAsStringSync(scopesContent);
    } else {
      final scopesPath = path.join(rootPath, '.dart_tool', 'jaspr', 'scopes.json');
      final file = io.File(scopesPath);
      if (!dirty && file.existsSync()) return;

      file.createSync(recursive: true);
      file.writeAsStringSync(scopesContent);
    }
    dirty = false;
  }

  Map<String, dynamic> buildScopes() {
    final serverScopes = <ScopeTreeNode, Set<NodeLocation>>{};
    final clientScopes = <ScopeTreeNode, Set<NodeLocation>>{};

    void setScopes(ScopeTreeNode node, Set<NodeLocation> parentServerScopes, Set<NodeLocation> parentClientScopes) {
      final nodeServerScopes = serverScopes[node] ??= {};
      final nodeClientScopes = clientScopes[node] ??= {};

      bool didSetScopes = false;

      if (node.serverScopeLocation case final location? when !nodeServerScopes.contains(location)) {
        nodeServerScopes.add(location);
        didSetScopes = true;
      }

      if (node.clientScopeLocation case final location? when !nodeClientScopes.contains(location)) {
        nodeClientScopes.add(location);
        didSetScopes = true;
      }

      if (parentServerScopes.isNotEmpty && parentServerScopes.any((s) => !nodeServerScopes.contains(s))) {
        nodeServerScopes.addAll(parentServerScopes);
        didSetScopes = true;
      }

      if (parentClientScopes.isNotEmpty && parentClientScopes.any((s) => !nodeClientScopes.contains(s))) {
        nodeClientScopes.addAll(parentClientScopes);
        didSetScopes = true;
      }

      if (didSetScopes) {
        for (final edge in node.childEdges) {
          setScopes(
            edge.childNode,
            edge.type != EdgeType.client ? nodeServerScopes : {},
            edge.type != EdgeType.server ? nodeClientScopes : {},
          );
        }
      }
    }

    for (final node in nodes.values) {
      setScopes(node, {}, {});
    }

    int locationIdCounter = 0;
    final locationIds = <String, String>{};
    final locations = <String, Object?>{};
    final scopes = <String, Object?>{};

    String putLocation(NodeLocation location) {
      final key = '${location.path}:${location.name}';
      final locationId = locationIds.putIfAbsent(key, () => '${locationIdCounter++}');
      locations[locationId] = location.toJson();
      return locationId;
    }

    for (final libraryPath in nodes.keys) {
      final node = nodes[libraryPath]!;

      if (node.components.isEmpty) {
        continue; // Skip libraries without components.
      }

      final nodeServerScopes = serverScopes[node] ??= {};
      final nodeClientScopes = clientScopes[node] ??= {};

      scopes[libraryPath] = {
        'components': [for (final location in node.components) putLocation(location)],
        if (nodeServerScopes.isNotEmpty)
          'serverScopeRoots': [for (final location in nodeServerScopes) putLocation(location)],
        if (nodeClientScopes.isNotEmpty)
          'clientScopeRoots': [for (final location in nodeClientScopes) putLocation(location)],
      };
    }

    return {
      'locations': locations,
      'scopes': scopes,
    };
  }
}

// A node in the scope tree, identified by a library.
class ScopeTreeNode {
  ScopeTreeNode(this.library, this.tree);

  LibraryElement library;
  final ScopeTree tree;

  bool dirty = true;

  NodeLocation? serverScopeLocation;
  NodeLocation? clientScopeLocation;
  bool usesCssAnnotation = false;

  final List<NodeLocation> components = [];

  final List<ScopeTreeEdge> parentEdges = [];
  final List<ScopeTreeEdge> childEdges = [];

  void analyzeSelf() {
    if (!dirty) return;

    final path = library.firstFragment.source.fullName;

    components.clear();
    serverScopeLocation = null;
    clientScopeLocation = null;

    for (final clazz in library.classes) {
      final location = clazz.firstFragment.libraryFragment.lineInfo.getLocation(
        clazz.firstFragment.nameOffset ?? clazz.firstFragment.offset,
      );
      if (clazz.isComponent) {
        final clazzLocation = NodeLocation(
          path,
          clazz.name ?? '',
          location.lineNumber,
          location.columnNumber,
          clazz.name?.length ?? 1,
        );
        components.add(clazzLocation);
        if (clazz.hasClientAnnotation) {
          clientScopeLocation = clazzLocation;
        }
      }
    }

    if (path.endsWith('.server.dart')) {
      serverScopeLocation = findMainFunction();
    }

    if (path.endsWith('.client.dart')) {
      clientScopeLocation = findMainFunction();
    }

    usesCssAnnotation = findCssAnnotation();
  }

  NodeLocation? findMainFunction() {
    final mainFunction = library.topLevelFunctions.where((e) => e.name == 'main').firstOrNull?.firstFragment;
    final mainLocation = mainFunction?.libraryFragment.lineInfo.getLocation(
      mainFunction.nameOffset ?? mainFunction.offset,
    );
    return NodeLocation(
      library.firstFragment.source.fullName,
      'main',
      mainLocation?.lineNumber ?? 0,
      mainLocation?.columnNumber ?? 0,
      4,
    );
  }

  bool findCssAnnotation() {
    final annotated = [...library.classes, ...library.topLevelVariables]
        .expand<Element>(
          (e) => switch (e) {
            final ClassElement e when !e.isPrivate => [
              ...e.fields.where((e) => e.isStatic),
              ...e.getters.where((e) => e.isStatic),
            ],
            final TopLevelVariableElement e when e.isOriginDeclaration => [e],
            TopLevelVariableElement(:final getter?) when e.isOriginGetterSetter => [getter],
            _ => [],
          },
        )
        .where((element) => !element.isPrivate)
        .where((element) => element.metadata.annotations.any((a) => a.isCssAnnotation));
    return annotated.isNotEmpty;
  }

  void analyzeChildren() {
    if (!dirty) return;

    if (childEdges.isNotEmpty) {
      for (final edge in childEdges) {
        edge.childNode.parentEdges.removeWhere((e) => e.parentNode.library.identifier == library.identifier);
      }
    }
    childEdges.clear();

    final dependencies = resolveDependencies(library);

    for (final (:lib, :dir, :config, :type) in dependencies) {
      final child = tree.inspectLibrary(lib);
      final edge = ScopeTreeEdge(this, child, dir, config, type);
      childEdges.add(edge);
      child.parentEdges.add(edge);
    }

    for (final edge in childEdges) {
      edge.childNode.analyzeChildren();
    }

    dirty = false;
  }

  List<({LibraryElement lib, UriBasedDirective dir, Configuration? config, EdgeType type})> resolveDependencies(
    LibraryElement library,
  ) {
    const frameworkPackages = [
      'jaspr',
      'jaspr_content',
      'jaspr_router',
      'jaspr_flutter_embed',
      'web',
      'universal_web',
      'flutter',
    ];
    if (library.isInSdk || frameworkPackages.any((p) => library.identifier.startsWith('package:$p/'))) {
      // Skip SDK and framework libraries.
      return [];
    }
    if (library.identifier.endsWith('.server.options.dart') || library.identifier.endsWith('.client.options.dart')) {
      // Skip generated option files.
      return [];
    }

    final result = library.session.getParsedLibraryByElement(library);
    if (result is! ParsedLibraryResult) {
      log('[Warning] ImportTreeNode.resolveDependencies: Failed to parse library ${library.uri}');
      return [];
    }

    final imports = library.fragments.expand((f) => f.libraryImports).toList();
    final exports = library.fragments.expand((f) => f.libraryExports).toList();

    LibraryElement? getBaseLibraryForDirective(NamespaceDirective directive) {
      bool matchesUri(ElementDirective d) => switch (d.uri) {
        final DirectiveUriWithRelativeUriString uri => uri.relativeUriString == directive.uri.stringValue,
        _ => false,
      };
      if (directive is ImportDirective) {
        return directive.libraryImport?.importedLibrary ?? imports.where(matchesUri).firstOrNull?.importedLibrary;
      } else if (directive is ExportDirective) {
        return directive.libraryExport?.exportedLibrary ?? exports.where(matchesUri).firstOrNull?.exportedLibrary;
      }
      return null;
    }

    LibraryElement? resolveLibraryFromUri(String? uri) {
      if (uri == null) return null;
      final absolutePath = library.session.uriConverter.uriToPath(library.uri.resolve(uri));
      if (absolutePath == null) return null;
      final result = library.session.getParsedLibrary(absolutePath);
      if (result is ParsedLibraryResult) {
        return result.units.first.unit.declaredFragment?.element;
      }
      return null;
    }

    final dependencies = <({LibraryElement lib, UriBasedDirective dir, Configuration? config, EdgeType type})>[];

    for (final unit in result.units) {
      for (final directive in unit.unit.directives) {
        if (directive is NamespaceDirective) {
          final configuration = directive.configurations;

          const clientLibs = ['js_interop', 'js_interop_unsafe', 'html', 'js', 'js_util'];
          const serverLibs = ['io', 'ffi', 'isolate', 'mirrors'];

          final libConfigurations = configuration.where(
            (c) =>
                c.name.components.length == 3 &&
                c.name.components[0].name == 'dart' &&
                c.name.components[1].name == 'library',
          );

          final clientConfiguration = libConfigurations
              .where((c) => clientLibs.contains(c.name.components.last.name))
              .firstOrNull;
          final serverConfiguration = libConfigurations
              .where((c) => serverLibs.contains(c.name.components.last.name))
              .firstOrNull;

          final baseLib = getBaseLibraryForDirective(directive);
          if (baseLib == null) {
            log(
              '[Warning] ImportTreeNode.resolveDependencies: Could not resolve base library for ${directive.uri.stringValue} in ${library.identifier}',
            );
          }

          if (clientConfiguration == null && serverConfiguration == null) {
            // This is a general import (or with unsupported configurations), add to general dependencies
            if (baseLib != null) {
              dependencies.add((lib: baseLib, dir: directive, config: null, type: EdgeType.general));
            }
            continue;
          }

          if (clientConfiguration != null) {
            final clientLib = resolveLibraryFromUri(clientConfiguration.uri.stringValue);
            if (clientLib != null) {
              dependencies.add((lib: clientLib, dir: directive, config: clientConfiguration, type: EdgeType.client));
            } else {
              log(
                '[Warning] ImportTreeNode.resolveDependencies: Could not resolve client library for ${clientConfiguration.uri.stringValue} in ${library.identifier}',
              );
            }
          } else {
            // On the client, the base import is used.
            if (baseLib != null) {
              dependencies.add((lib: baseLib, dir: directive, config: null, type: EdgeType.client));
            }
          }

          if (serverConfiguration != null) {
            final serverLib = resolveLibraryFromUri(serverConfiguration.uri.stringValue);
            if (serverLib != null) {
              dependencies.add((lib: serverLib, dir: directive, config: serverConfiguration, type: EdgeType.server));
            } else {
              log(
                '[Warning] Could not resolve server library for ${serverConfiguration.uri.stringValue} in ${library.identifier}',
              );
            }
          } else {
            // On the server, the base import is used.
            if (baseLib != null) {
              dependencies.add((lib: baseLib, dir: directive, config: null, type: EdgeType.server));
            }
          }
        }
      }
    }

    return dependencies;
  }
}

// An edge in the scope tree, representing a single import or export directive.
class ScopeTreeEdge {
  ScopeTreeEdge(this.parentNode, this.childNode, this.directive, this.configuration, this.type);

  final ScopeTreeNode parentNode;
  final ScopeTreeNode childNode;
  final UriBasedDirective directive;
  final Configuration? configuration;
  final EdgeType type;
}

enum EdgeType { general, client, server }

/// The location of a ast declaration.
class NodeLocation {
  final String path;
  final String name;
  final int line;
  final int character;
  final int length;

  NodeLocation(this.path, this.name, this.line, this.character, this.length);

  Map<String, Object?> toJson() {
    return {'path': path, 'name': name, 'line': line, 'char': character, 'length': length};
  }
}

extension on ClassElement {
  bool get isComponent {
    return allSupertypes.any(
      (e) =>
          e.element.name == 'Component' && e.element.library.identifier == 'package:jaspr/src/framework/framework.dart',
    );
  }

  bool get hasClientAnnotation {
    return metadata.annotations.any(
      (a) =>
          a.element?.name == 'client' &&
          a.element?.library?.identifier == 'package:jaspr/src/foundation/annotations.dart',
    );
  }
}

extension CheckElementAnnotation on ElementAnnotation {
  bool get isCssAnnotation {
    return element?.name == 'css' && element?.library?.identifier == 'package:jaspr/src/dom/styles/css.dart';
  }
}
