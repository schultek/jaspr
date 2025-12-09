import 'utils.dart';

/// An enumeration of possible assist kinds.
abstract final class JasprAssistKind {
  static const createStatelessComponent = AssistKind(
    'jaspr.assist.createStatelessComponent',
    DartFixKindPriority.standard + 3,
    'Create StatelessComponent',
  );

  static const createStatefulComponent = AssistKind(
    'jaspr.assist.createStatefulComponent',
    DartFixKindPriority.standard + 2,
    'Create StatefulComponent',
  );

  static const createInheritedComponent = AssistKind(
    'jaspr.assist.createInheritedComponent',
    DartFixKindPriority.standard + 1,
    'Create InheritedComponent',
  );

  static const convertToStatefulComponent = AssistKind(
    'jaspr.assist.convertToStatefulComponent',
    DartFixKindPriority.standard + 2,
    'Convert to StatefulComponent',
  );

  static const convertToAsyncStatelessComponent = AssistKind(
    'jaspr.assist.convertToAsyncStatelessComponent',
    DartFixKindPriority.standard + 1,
    'Convert to AsyncStatelessComponent',
  );

  static const convertToNestedStyles = AssistKind(
    'jaspr.assist.convertToNestedStyles',
    DartFixKindPriority.standard + 2,
    'Convert to nested styles',
  );

  static const convertToWebImport = AssistKind(
    'jaspr.assist.convertToWebImport',
    DartFixKindPriority.standard + 2,
    'Convert to web-only import',
  );

  static const convertToServerImport = AssistKind(
    'jaspr.assist.convertToServerImport',
    DartFixKindPriority.standard + 1,
    'Convert to server-only import',
  );

  static const addStyles = AssistKind(
    'jaspr.assist.addStyles',
    DartFixKindPriority.standard + 10,
    'Add styles',
  );

  static const wrapWithHtml = AssistKind(
    'jaspr.assist.wrapWithHtml',
    DartFixKindPriority.standard + 9,
    'Wrap with html...',
  );

  static const wrapWithComponent = AssistKind(
    'jaspr.assist.wrapWithComponent',
    DartFixKindPriority.standard + 8,
    'Wrap with component...',
  );

  static const wrapWithBuilder = AssistKind(
    'jaspr.assist.wrapWithBuilder',
    DartFixKindPriority.standard + 7,
    'Wrap with Builder',
  );

  static const removeComponent = AssistKind(
    'jaspr.assist.removeComponent',
    DartFixKindPriority.standard + 6,
    'Remove this Component',
  );

  static const extractComponent = AssistKind(
    'jaspr.assist.extractComponent',
    DartFixKindPriority.standard + 5,
    'Extract to StatelessComponent',
  );
}
