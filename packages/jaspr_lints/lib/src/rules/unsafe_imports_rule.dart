import 'package:analyzer/analysis_rule/analysis_rule.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/diagnostic/diagnostic.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:yaml/yaml.dart';

import '../utils.dart';
import '../utils/scope_tree.dart';

class UnsafeImportsRule extends AnalysisRule {
  static const LintCode code = LintCode(
    'unsafe_imports',
    'Unsafe import: {0}',
    severity: DiagnosticSeverity.ERROR,
  );

  UnsafeImportsRule({this.resourceProvider})
    : super(
        name: 'unsafe_imports',
        description: 'Detects unsafe platform imports.',
      );

  final ResourceProvider? resourceProvider;

  final ScopeTree scopeTree = ScopeTree();

  @override
  LintCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
    final library = context.libraryElement!;

    final node = scopeTree.analyzeLibrary(library);

    if (node.serverScopeLocation != null) {
      registry.addImportDirective(this, ServerScopeImportsVisitor(this, node));
    }

    if (node.clientScopeLocation != null) {
      _checkPubspecConfig(context);
      registry.addImportDirective(this, ClientScopeImportsVisitor(this, node, allowFlutterLibsInClient));
    }

    if (context.package?.root case final root?) {
      scopeTree.writeScopes(root.path, resourceProvider: resourceProvider);
    }
  }

  int pubspecDigest = 0;
  bool allowFlutterLibsInClient = false;
  void _checkPubspecConfig(RuleContext context) {
    final session = context.libraryElement?.session;
    if (session == null) return;
    final pubspecFile = session.analysisContext.contextRoot.root.getChildAssumingFile('pubspec.yaml');
    final digest = pubspecFile.lengthSync ^ pubspecFile.modificationStamp;
    if (digest == pubspecDigest) return;
    pubspecDigest = digest;

    final pubspec = loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    if (pubspec case {'jaspr': {'flutter': 'embedded' || 'plugins'}}) {
      allowFlutterLibsInClient = true;
    } else {
      allowFlutterLibsInClient = false;
    }
  }
}

abstract class ScopeImportsVisitor extends SimpleAstVisitor<void> {
  ScopeImportsVisitor(this.rule, this.treeNode, {required this.edgeType});

  final UnsafeImportsRule rule;
  final ScopeTreeNode treeNode;
  final EdgeType edgeType;

  @override
  void visitImportDirective(ImportDirective node) {
    for (final edge in treeNode.childEdges) {
      if (allowsEdge(edge) && edge.directive.toSource() == node.toSource()) {
        if (isUnsafeImport(edge.childNode.library)) {
          reportUnsafeDirectImport(edge);
        } else {
          checkUnsafeTransitiveImports(edge);
        }
      }
    }
  }

  bool allowsEdge(ScopeTreeEdge edge) {
    return edge.type == EdgeType.general || edge.type == edgeType;
  }

  void reportUnsafeDirectImport(ScopeTreeEdge edge) {
    rule.reportAtNode(
      edge.directive,
      arguments: [
        "'${edge.directive.uri.stringValue}' is not available on the ${edgeType.name}.\n${suggestionFor(edge.childNode.library)}",
      ],
    );
  }

  void checkUnsafeTransitiveImports(ScopeTreeEdge edge) {
    final visited = <String>{};
    final messages = <DiagnosticMessage>[];

    late void Function(ScopeTreeEdge) recurseEdge;

    void recurseEdges(ScopeTreeNode node) {
      for (final childEdge in node.childEdges) {
        if (allowsEdge(childEdge)) {
          recurseEdge(childEdge);
        }
      }
    }

    recurseEdge = (ScopeTreeEdge childEdge) {
      if (visited.contains(childEdge.directive.uri.stringValue)) return;
      visited.add(childEdge.directive.uri.stringValue!);

      if (isUnsafeImport(childEdge.childNode.library)) {
        final importUri = childEdge.configuration?.uri ?? childEdge.directive.uri;
        messages.add(
          SimpleDiagnosticMessage(
            filePath: childEdge.parentNode.library.firstFragment.source.fullName,
            offset: importUri.offset,
            length: importUri.length,
            message: "Unsafe import '${importUri.stringValue}'. ${suggestionFor(childEdge.childNode.library)}",
          ),
        );
        return;
      }

      recurseEdges(childEdge.childNode);
    };

    recurseEdges(edge.childNode);

    if (messages.isNotEmpty) {
      rule.reportAtNode(
        edge.directive,
        arguments: [
          "'${edge.directive.uri.stringValue}' imports other unsafe libraries which are not available on the ${edgeType.name}. See below for details.",
        ],
        contextMessages: messages,
      );
    }
  }

  bool isUnsafeImport(LibraryElement lib);
  String suggestionFor(LibraryElement lib);
}

class ServerScopeImportsVisitor extends ScopeImportsVisitor {
  ServerScopeImportsVisitor(super.rule, super.treeNode) : super(edgeType: EdgeType.server);

  @override
  bool isUnsafeImport(LibraryElement lib) {
    return lib.identifier == 'package:jaspr/client.dart' ||
        lib.identifier == 'package:web/web.dart' ||
        lib.identifier == 'dart:js_interop' ||
        lib.identifier == 'dart:js_interop_unsafe' ||
        lib.identifier == 'dart:html' ||
        lib.identifier == 'dart:js' ||
        lib.identifier == 'dart:js_util' ||
        lib.identifier.startsWith('package:flutter/');
  }

  @override
  String suggestionFor(LibraryElement lib) {
    if (lib.identifier == 'package:jaspr/client.dart') {
      return "Try using 'package:jaspr/jaspr.dart' instead.";
    } else if (lib.identifier == 'package:web/web.dart') {
      return "Try using 'package:universal_web/web.dart' instead.";
    } else if (lib.identifier == 'dart:js_interop') {
      return "Try using 'package:universal_web/js_interop.dart' instead.";
    }
    return 'Try using a platform-independent library or conditional import.';
  }
}

class ClientScopeImportsVisitor extends ScopeImportsVisitor {
  ClientScopeImportsVisitor(super.rule, super.treeNode, this.allowFlutterLibsInClient)
    : super(edgeType: EdgeType.client);

  final bool allowFlutterLibsInClient;

  @override
  bool isUnsafeImport(LibraryElement lib) {
    return lib.identifier == 'package:jaspr/server.dart' ||
        lib.identifier == 'package:jaspr_content/jaspr_content.dart' ||
        (!allowFlutterLibsInClient && lib.identifier == 'dart:io') ||
        (!allowFlutterLibsInClient && lib.identifier.startsWith('package:flutter/')) ||
        lib.identifier == 'dart:ffi' ||
        lib.identifier == 'dart:isolate' ||
        lib.identifier == 'dart:mirrors';
  }

  @override
  String suggestionFor(LibraryElement lib) {
    if (lib.identifier == 'package:jaspr/server.dart') {
      return "Try using 'package:jaspr/jaspr.dart' instead.";
    }
    return 'Try moving this out of the client scope or use a conditional import.';
  }
}

class SimpleDiagnosticMessage implements DiagnosticMessage {
  SimpleDiagnosticMessage({
    required this.filePath,
    required this.offset,
    required this.length,
    required this.message,
  });

  @override
  final String filePath;

  @override
  final int offset;
  @override
  final int length;

  final String message;

  @override
  String messageText({required bool includeUrl}) => message;

  @override
  String? get url => null;
}
