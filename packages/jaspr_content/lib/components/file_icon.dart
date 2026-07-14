import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '_internal/file_tree_icons.dart';

/// A component that renders a file or folder icon based on a given filename or icon name.
///
/// It uses the Seti icon set (packaged internally) to determine the appropriate SVG icon path.
class FileIcon extends StatelessComponent {
  /// Creates a [FileIcon] with a specific [iconName].
  const FileIcon(this.iconName, {this.classes, this.attributes});

  /// Creates a [FileIcon] matching the provided [filename] by resolving its extension or name.
  factory FileIcon.forFile(String filename, {String? classes, Map<String, String>? attributes}) {
    return FileIcon(_getIconName(filename), classes: classes, attributes: attributes);
  }

  /// The name of the icon (e.g., `seti:dart` or `seti:default`).
  final String iconName;

  /// CSS classes to apply to the rendered SVG element.
  final String? classes;

  /// Custom HTML attributes to apply to the rendered SVG element.
  final Map<String, String>? attributes;

  static const String _defaultIconName = 'seti:default';

  /// A default file icon.
  static const FileIcon defaultIcon = FileIcon(_defaultIconName);

  static const String _folderIconName = 'seti:folder';

  /// A default folder icon.
  static const FileIcon folderIcon = FileIcon(_folderIconName);

  /// Whether this is the default file icon.
  bool get isDefault => iconName == _defaultIconName;

  /// Whether this is the default folder icon.
  bool get isFolder => iconName == _folderIconName;

  /// The SVG path content of this icon.
  String? get svgPath => fileIcons[iconName];

  @override
  Component build(BuildContext context) {
    return svg(
      classes: classes,
      viewBox: '0 0 24 24',
      attributes: {'fill': 'currentColor', 'width': '16', 'height': '16', ...?attributes},
      [
        RawText(fileIcons[iconName] ?? ''),
      ],
    );
  }
}

String _getIconName(String fileName) {
  String? icon = definitions['files']![fileName];
  if (icon != null) {
    return icon;
  }
  icon = _getFileIconTypeFromExtension(fileName);
  if (icon != null) return icon;
  for (final MapEntry(key: partial, value: partialIcon) in definitions['partials']!.entries) {
    if (fileName.contains(partial)) return partialIcon;
  }
  return FileIcon._defaultIconName;
}

String? _getFileIconTypeFromExtension(String fileName) {
  final firstDotIndex = fileName.indexOf('.');
  if (firstDotIndex == -1) return null;
  var extension = fileName.substring(firstDotIndex);
  while (extension.isNotEmpty) {
    final icon = definitions['extensions']![extension];
    if (icon != null) return icon;
    final nextDotIndex = extension.indexOf('.', 1);
    if (nextDotIndex == -1) return null;
    extension = extension.substring(nextDotIndex);
  }
  return null;
}
