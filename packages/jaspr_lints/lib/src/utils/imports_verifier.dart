// Copied from analyzer-6.5.0/lib/src/error/imports_verifier.dart

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

/// A visitor that visits ASTs and fills [UsedImportedElements].
class GatherUsedImportedElementsVisitor extends RecursiveAstVisitor<void> {
  final LibraryElement library;
  final UsedImportedElements usedElements = UsedImportedElements();

  GatherUsedImportedElementsVisitor(this.library);

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    _recordAssignmentTarget(node, node.leftHandSide);
    return super.visitAssignmentExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    _recordIfExtensionMember(node.staticElement);
    return super.visitBinaryExpression(node);
  }

  @override
  void visitExportDirective(ExportDirective node) {
    _visitDirective(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    _recordIfExtensionMember(node.staticElement);
    return super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    _visitDirective(node);
  }

  @override
  void visitIndexExpression(IndexExpression node) {
    _recordIfExtensionMember(node.staticElement);
    return super.visitIndexExpression(node);
  }

  @override
  void visitLibraryDirective(LibraryDirective node) {
    _visitDirective(node);
  }

  @override
  void visitNamedType(NamedType node) {
    _recordPrefixedElement(node.importPrefix, node.element);
    super.visitNamedType(node);
  }

  @override
  void visitPatternField(PatternField node) {
    _recordIfExtensionMember(node.element);
    super.visitPatternField(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    _recordAssignmentTarget(node, node.operand);
    return super.visitPostfixExpression(node);
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    _recordAssignmentTarget(node, node.operand);
    _recordIfExtensionMember(node.staticElement);
    return super.visitPrefixExpression(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    _visitIdentifier(node, node.staticElement);
  }

  void _recordAssignmentTarget(
    CompoundAssignmentExpression node,
    Expression target,
  ) {
    if (target is IndexExpression) {
      _recordIfExtensionMember(node.readElement);
      _recordIfExtensionMember(node.writeElement);
    } else if (target is PrefixedIdentifier) {
      _visitIdentifier(target.identifier, node.readElement);
      _visitIdentifier(target.identifier, node.writeElement);
    } else if (target is PropertyAccess) {
      _visitIdentifier(target.propertyName, node.readElement);
      _visitIdentifier(target.propertyName, node.writeElement);
    } else if (target is SimpleIdentifier) {
      _visitIdentifier(target, node.readElement);
      _visitIdentifier(target, node.writeElement);
    }
  }

  void _recordIfExtensionMember(Element? element) {
    if (element != null) {
      // ignore: deprecated_member_use
      var enclosingElement = element.enclosingElement;
      if (enclosingElement is ExtensionElement) {
        _recordUsedExtension(enclosingElement);
      }
    }
  }

  void _recordPrefixedElement(
    ImportPrefixReference? importPrefix,
    Element? element,
  ) {
    if (element is MultiplyDefinedElement) {
      for (var component in element.conflictingElements) {
        _recordPrefixedElement(importPrefix, component);
        return;
      }
    }

    // Invalid code can use `importPrefix` as a named type;
    if (element is PrefixElement) {
      usedElements.prefixMap[element] ??= [];
      return;
    }

    if (importPrefix != null) {
      var prefixElement = importPrefix.element;
      if (prefixElement is PrefixElement) {
        var map = usedElements.prefixMap[prefixElement] ??= [];
        if (element != null) {
          map.add(element);
        }
      }
    } else if (element != null) {
      _recordUsedElement(element);
    }
  }

  /// If the given [identifier] is prefixed with a [PrefixElement], fill the
  /// corresponding `UsedImportedElements.prefixMap` entry and return `true`.
  bool _recordPrefixMap(SimpleIdentifier identifier, Element element) {
    bool recordIfTargetIsPrefixElement(Expression? target) {
      if (target is SimpleIdentifier) {
        var targetElement = target.staticElement;
        if (targetElement is PrefixElement) {
          List<Element> prefixedElements = usedElements.prefixMap
              .putIfAbsent(targetElement, () => <Element>[]);
          prefixedElements.add(element);
          return true;
        }
      }
      return false;
    }

    var parent = identifier.parent;
    if (parent is MethodInvocation && parent.methodName == identifier) {
      return recordIfTargetIsPrefixElement(parent.target);
    }
    if (parent is PrefixedIdentifier && parent.identifier == identifier) {
      return recordIfTargetIsPrefixElement(parent.prefix);
    }
    return false;
  }

  /// Records use of an unprefixed [element].
  void _recordUsedElement(Element element) {
    // Ignore if an unknown library.
    var containingLibrary = element.library;
    if (containingLibrary == null) {
      return;
    }
    // Ignore if a local element.
    if (library == containingLibrary) {
      return;
    }
    // Remember the element.
    usedElements.elements.add(element);
  }

  void _recordUsedExtension(ExtensionElement extension) {
    // Ignore if a local element.
    if (library == extension.library) {
      return;
    }
    // Remember the element.
    usedElements.usedExtensions.add(extension);
  }

  /// Visit identifiers used by the given [directive].
  void _visitDirective(Directive directive) {
    directive.documentationComment?.accept(this);
    directive.metadata.accept(this);
  }

  void _visitIdentifier(SimpleIdentifier identifier, Element? element) {
    if (element == null) {
      return;
    }
    // Record `importPrefix.identifier` into 'prefixMap'.
    if (_recordPrefixMap(identifier, element)) {
      return;
    }
    // ignore: deprecated_member_use
    var enclosingElement = element.enclosingElement;
    if (enclosingElement is CompilationUnitElement) {
      _recordUsedElement(element);
    } else if (enclosingElement is ExtensionElement) {
      _recordUsedExtension(enclosingElement);
      return;
    } else if (element is PrefixElement) {
      usedElements.prefixMap.putIfAbsent(element, () => <Element>[]);
    } else if (element is MultiplyDefinedElement) {
      // If the element is multiply defined then call this method recursively
      // for each of the conflicting elements.
      List<Element> conflictingElements = element.conflictingElements;
      int length = conflictingElements.length;
      for (int i = 0; i < length; i++) {
        Element elt = conflictingElements[i];
        _visitIdentifier(identifier, elt);
      }
    }
  }
}


/// A container with information about used imports prefixes and used imported
/// elements.
class UsedImportedElements {
  /// The map of referenced prefix elements and the elements that they prefix.
  final Map<PrefixElement, List<Element>> prefixMap = {};

  /// The set of referenced top-level elements.
  final Set<Element> elements = {};

  /// The set of extensions defining members that are referenced.
  final Set<ExtensionElement> usedExtensions = {};
}