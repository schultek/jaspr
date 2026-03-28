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

class UnsafeImportsRule extends MultiAnalysisRule {
  static const LintCode unsafeImportCode = LintCode(
    'unsafe_imports',
    'Unsafe import: {0}',
    severity: DiagnosticSeverity.WARNING,
  );

  static const LintCode unsafeCssCode = LintCode(
    'unsafe_css',
    'Unsafe @css usage: {0}',
    severity: DiagnosticSeverity.WARNING,
  );

  UnsafeImportsRule({this.resourceProvider})
    : super(
        name: 'unsafe_imports',
        description: 'Detects unsafe platform imports.',
      );

  @override
  List<DiagnosticCode> get diagnosticCodes => [unsafeImportCode, unsafeCssCode];

  final ResourceProvider? resourceProvider;

  final ScopeTree scopeTree = ScopeTree();

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

    if (node.usesCssAnnotation) {
      registry.addAnnotation(this, CssImportsVisitor(this, node));
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

abstract mixin class ScopeEdgeVisitor {
  EdgeType get edgeType;

  bool allowsEdge(ScopeTreeEdge edge) {
    return edge.type == EdgeType.general || edge.type == edgeType;
  }

  List<DiagnosticMessage> collectUnsafeImports(
    ScopeTreeEdge edge, {
    bool checkRoot = false,
    bool Function(ScopeTreeNode node)? filterNode,
  }) {
    final visited = <String>{};
    final messages = <DiagnosticMessage>[];

    late void Function(ScopeTreeEdge) recurseEdge;

    void recurseEdges(ScopeTreeNode node) {
      if (filterNode != null && filterNode(node)) return;

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

    if (checkRoot) {
      recurseEdge(edge);
    } else {
      recurseEdges(edge.childNode);
    }

    return messages;
  }

  bool isUnsafeImport(LibraryElement lib);
  String suggestionFor(LibraryElement lib);
}

abstract class ScopeImportsVisitor extends SimpleAstVisitor<void> with ScopeEdgeVisitor {
  ScopeImportsVisitor(this.rule, this.treeNode);

  final UnsafeImportsRule rule;
  final ScopeTreeNode treeNode;

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

  void reportUnsafeDirectImport(ScopeTreeEdge edge) {
    rule.reportAtNode(
      edge.directive,
      arguments: [
        "'${edge.directive.uri.stringValue}' is not available on the ${edgeType.name}.\n${suggestionFor(edge.childNode.library)}",
      ],
      diagnosticCode: UnsafeImportsRule.unsafeImportCode,
    );
  }

  void checkUnsafeTransitiveImports(ScopeTreeEdge edge) {
    final messages = collectUnsafeImports(edge);

    if (messages.isNotEmpty) {
      rule.reportAtNode(
        edge.directive,
        arguments: [
          "'${edge.directive.uri.stringValue}' imports other unsafe libraries which are not available on the ${edgeType.name}. See below for details.",
        ],
        contextMessages: messages,
        diagnosticCode: UnsafeImportsRule.unsafeImportCode,
      );
    }
  }
}

abstract mixin class ServerScopeEdgeVisitor implements ScopeEdgeVisitor {
  @override
  EdgeType get edgeType => EdgeType.server;

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

class ServerScopeImportsVisitor extends ScopeImportsVisitor with ServerScopeEdgeVisitor {
  ServerScopeImportsVisitor(super.rule, super.treeNode);
}

class ClientScopeImportsVisitor extends ScopeImportsVisitor {
  ClientScopeImportsVisitor(super.rule, super.treeNode, this.allowFlutterLibsInClient);

  final bool allowFlutterLibsInClient;

  @override
  EdgeType get edgeType => EdgeType.client;

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

class CssImportsVisitor extends SimpleAstVisitor<void> with ScopeEdgeVisitor, ServerScopeEdgeVisitor {
  CssImportsVisitor(this.rule, this.treeNode);

  final UnsafeImportsRule rule;
  final ScopeTreeNode treeNode;

  @override
  void visitAnnotation(Annotation node) {
    if (node case Annotation(
      name: Identifier(name: 'css'),
      elementAnnotation: ElementAnnotation(isCssAnnotation: true),
    )) {
      final messages = [
        for (final edge in treeNode.childEdges)
          ...collectUnsafeImports(
            edge,
            checkRoot: true,
            filterNode: (node) {
              // Skip nodes that also use @css themself, to avoid double-reporting.
              if (node.usesCssAnnotation) return true;
              return false;
            },
          ),
      ];

      if (messages.isNotEmpty) {
        rule.reportAtNode(
          node,
          arguments: [
            'Importing client-only libraries is not allowed when using @css. See below for details.',
          ],
          contextMessages: messages,
          diagnosticCode: UnsafeImportsRule.unsafeCssCode,
        );
      }
    }
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
