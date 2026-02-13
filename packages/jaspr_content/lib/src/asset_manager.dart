/// @docImport 'package:jaspr/server.dart';
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:jaspr/jaspr.dart';
import 'package:path/path.dart' as p;
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';

import '../jaspr_content.dart';

/// Manages assets and resolves relative asset paths in rendered pages.
///
/// Use this class when you want to co-locate your assets (images, videos, etc.) with your content.
/// Relative asset paths in the page data (e.g. in frontmatter data) or the page content (e.g. in `<img>` tags)
/// will be resolved to absolute paths based to be used in the rendered pages.
///
/// ## Setup
///
/// Create a new [AssetManager] instance in your main method and configure it in your [ContentApp] like this:
///
/// ```dart
/// void main() {
///   final assetManager = AssetManager(/* ... */);
///
///   // Add middleware to serve assets.
///   ServerApp.addMiddleware(assetManager.middleware);
///
///   runApp(ContentApp(
///     // ...,
///     dataLoaders: [
///       // ...,
///       // Add data loader to process relative asset paths in page data.
///       assetManager.dataLoader,
///     ],
///     extensions: [
///       // ...,
///       // Add extension to process relative asset paths in page content.
///       assetManager.pageExtension,
///     ],
///   ));
/// }
/// ```
///
/// ## Usage
///
/// There are three ways relative asset paths are resolved:
///
/// 1. Relative paths in properties of the page data are resolved using [dataProperties].
///
///    For example, when having a `thumbnailImage` property in the frontmatter data of a page, you can add
///    `'page.thumbnailImage'` to [dataProperties] to resolve any relative paths in this property.
///
/// 2. Relative paths in `<img>`, `<video>`, `<audio>` and `<source>` elements in the page content are
///    automatically resolved.
///
///    This also works for images in markdown content.
///
/// 3. To resolve relative paths in your own components, use the [ResolveAssetExtension.resolveAsset] extension method on [BuildContext].
///
///    ```dart
///    @override
///    Component build(BuildContext context) {
///      final imagePath = context.resolveAsset(myRelativePath);
///      return img(src: imagePath);
///    }
///    ```
///
/// ---
///
/// During development, assets are served directly from the [directory].
///
/// When building (in `static` mode), assets are copied to the build/jaspr/[outputPrefix] directory.
class AssetManager {
  /// The default set of file extensions treated as assets.
  ///
  /// This is the default value for [assetExtensions] and includes
  /// common image, video, and audio formats.
  static const defaultAssetExtensions = {
    '.png',
    '.jpg',
    '.jpeg',
    '.jxl',
    '.gif',
    '.svg',
    '.webp',
    '.avif',
    '.ico',
    '.mp4',
    '.webm',
    '.ogg',
    '.mp3',
    '.wav',
    '.flac',
    '.aac',
    '.m4a',
  };

  static const _dataKey = '__asset_manager';

  AssetManager({
    required this.directory,
    this.outputPrefix = 'assets',
    this.assetExtensions = defaultAssetExtensions,
    this.dataProperties = const {},
    this.assetTransformers = const [HashingAssetTransformer()],
    this.filterPages,
  });

  /// The directory containing the assets.
  ///
  /// When co-locating the assets with the content, set this to the same directory as
  /// the content directory.
  final String directory;

  /// The prefix to use for the assets paths in the output directory.
  ///
  /// Defaults to `assets`. This is added as a prefix to the resolved asset path and
  /// sets the output directory for the assets relative to the build directory.
  final String outputPrefix;

  /// The file extensions recognized as assets, including
  /// the leading dot (such as `'.png'` for PNG images).
  ///
  /// If not specified, defaults to [defaultAssetExtensions].
  final Set<String> assetExtensions;

  /// The page properties to be processed.
  ///
  /// Nested properties can be specified using dot notation, e.g. `page.image` to process the
  /// `image` property of the page's frontmatter data.
  final Set<String> dataProperties;

  /// The asset transformers to use for processing assets.
  ///
  /// Asset transformers are applied during build time in the order they are provided.
  /// They can be used to transform assets, e.g. by adding a hash to the filename.
  ///
  /// Defaults to [HashingAssetTransformer].
  final List<AssetTransformer> assetTransformers;

  /// A function to filter pages to be processed.
  final bool Function(Page page)? filterPages;

  /// Processes pages and resolves all relative asset paths in the page data based on
  /// the [dataProperties].
  ///
  /// Should be passed to [PageConfig.dataLoaders].
  DataLoader get dataLoader => _AssetDataLoader(this);

  /// Processes pages and resolves all relative asset paths in media elements in the page content.
  /// Handles `<img>`, `<video>`, `<audio>` and `<source>` elements.
  ///
  /// Should be passed to [PageConfig.extensions].
  PageExtension get pageExtension => _AssetPageExtension(assetManager: this);

  /// Server middleware to serve the assets.
  ///
  /// Should be passed to [ServerApp.addMiddleware] before calling [runApp].
  Middleware get middleware => (handler) {
    final imageHandler = createStaticHandler(directory);

    return (request) {
      if (request.url.path.startsWith('$outputPrefix/')) {
        return imageHandler(request.change(path: outputPrefix));
      }
      return handler(request);
    };
  };

  final Map<(String, Object?), String> _assets = {};

  /// Retrieves the [AssetManager] for the given [page].
  static AssetManager? of(Page page) {
    final maybeAssetManager = page.data[_dataKey];
    if (maybeAssetManager is! AssetManager) return null;
    return maybeAssetManager;
  }

  /// Resolves the asset at [path] relative to the current page. If [path] starts with a slash, it is resolved
  /// relative to the asset root.
  ///
  /// The optional [aspect] parameter can be used to provide additional information to the asset transformers during build.
  /// Requires an [AssetManager] to be setup.
  String resolveAsset(String path, Page page, [Object? aspect]) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    final resolvedPath = path.startsWith('/')
        ? path.substring(1)
        : p.url.normalize(p.url.join(p.url.dirname(page.path), path));

    if (kGenerateMode) {
      final sourcePath = p.normalize(p.join(directory, p.fromUri(resolvedPath)));
      if (_assets.containsKey((sourcePath, aspect))) {
        return _assets[(sourcePath, aspect)]!;
      }

      var asset = Asset.fromFile(resolvedPath, File(sourcePath));
      for (final transformer in assetTransformers) {
        asset = transformer.transform(asset, aspect);
      }

      switch (asset) {
        case FileAsset(file: final file):
          final outFile = File(
            p.join('build', 'jaspr', outputPrefix, p.fromUri(asset.path)),
          );
          outFile.createSync(recursive: true);
          file.copySync(outFile.path);
        case MemoryAsset(bytes: final bytes):
          final outFile = File(
            p.join('build', 'jaspr', outputPrefix, p.fromUri(asset.path)),
          );
          outFile
            ..createSync(recursive: true)
            ..writeAsBytesSync(bytes);
      }

      return _assets[(sourcePath, aspect)] = p.url.join('/', outputPrefix, asset.path);
    }

    return p.url.normalize(p.url.join('/', outputPrefix, resolvedPath));
  }

  bool _shouldProcessPage(Page page) {
    return filterPages == null || filterPages!(page);
  }
}

extension ResolveAssetExtension on BuildContext {
  /// Resolves the asset at [path] relative to the current page. If [path] starts with a slash, it is resolved
  /// relative to the asset root.
  ///
  /// The optional [aspect] parameter can be used to provide additional information to the asset transformers during build.
  /// Requires an [AssetManager] to be setup.
  String resolveAsset(String path, {Object? aspect}) {
    final assetManager = AssetManager.of(page);
    if (assetManager == null) {
      throw StateError(
        'AssetManager not found for page ${page.path}. Make sure to add `assetManager.dataLoader` to your `ContentApp`.',
      );
    }
    return assetManager.resolveAsset(path, page, aspect);
  }
}

/// Represents an asset that can be processed by [AssetTransformer].
sealed class Asset {
  const Asset();

  /// Creates an asset from the specified [bytes].
  factory Asset.fromBytes(String path, Uint8List bytes) = MemoryAsset;

  /// Creates an asset from the specified [file].
  factory Asset.fromFile(String path, File file) = FileAsset;

  /// The path of the asset.
  String get path;

  /// Reads the asset as bytes.
  Uint8List readAsBytes();
}

/// An asset that is stored in memory as [bytes].
class MemoryAsset extends Asset {
  const MemoryAsset(this.path, this.bytes);

  @override
  final String path;
  final Uint8List bytes;

  @override
  Uint8List readAsBytes() => bytes;
}

/// An asset that is stored in a [file].
class FileAsset extends Asset {
  FileAsset(this.path, this.file) {
    if (!file.existsSync()) {
      throw StateError('Asset file not found: ${file.path}');
    }
  }

  @override
  final String path;
  final File file;

  Uint8List? _bytes;

  @override
  Uint8List readAsBytes() => _bytes ??= file.readAsBytesSync();
}

/// Interface for transforming assets during build time.
///
/// Use this interface to implement custom asset transformations.
abstract class AssetTransformer {
  const AssetTransformer();

  /// Transforms the given [asset].
  ///
  /// The optional [aspect] parameter can be used to provide additional information to the transformer.
  Asset transform(Asset asset, [Object? aspect]);
}

/// An asset transformer that adds a hash to the filename of assets.
///
/// This is useful for cache busting.
class HashingAssetTransformer extends AssetTransformer {
  const HashingAssetTransformer({this.flattenPath = true});

  /// Whether to flatten the path of the asset.
  ///
  /// If `true`, the path will be flattened to a single level, e.g. `images/foo/bar.png` becomes `bar.<hash>.png`.
  /// If `false`, the path will be preserved, e.g. `images/foo/bar.png` becomes `images/foo/bar.<hash>.png`.
  final bool flattenPath;

  @override
  Asset transform(Asset asset, [Object? aspect]) {
    final inputBytes = asset.readAsBytes();
    final digest = md5.convert(inputBytes);
    final hex = digest.toString();

    final pathWithoutExt = flattenPath
        ? p.url.basenameWithoutExtension(asset.path)
        : p.url.withoutExtension(asset.path);
    final outputPath = '$pathWithoutExt.$hex${p.url.extension(asset.path)}';

    return Asset.fromBytes(outputPath, inputBytes);
  }
}

class _AssetDataLoader implements DataLoader {
  const _AssetDataLoader(this.assetManager);

  final AssetManager assetManager;

  @override
  Future<void> loadData(Page page) async {
    if (!assetManager._shouldProcessPage(page)) {
      return;
    }

    final updates = <String, Object?>{};
    for (final property in assetManager.dataProperties) {
      final segments = property.split('.');
      var currentUpdates = updates;
      Object? currentData = page.data;
      for (final segment in segments.take(segments.length - 1)) {
        if (currentData is Map<String, Object?>) {
          currentData = currentData[segment];
          if (currentUpdates[segment] is! Map<String, Object?>) {
            currentUpdates[segment] = <String, Object?>{};
          }
          currentUpdates = currentUpdates[segment] as Map<String, Object?>;
        } else {
          currentData = null;
          break;
        }
      }
      if (currentData is Map<String, Object?>) {
        final lastSegment = segments.last;
        if (currentData[lastSegment] case final String pathValue) {
          currentUpdates[lastSegment] = assetManager.resolveAsset(pathValue, page);
        }
      }
    }

    page.apply(data: {...updates, AssetManager._dataKey: assetManager});
  }
}

class _AssetPageExtension implements PageExtension {
  const _AssetPageExtension({required this.assetManager});

  final AssetManager assetManager;

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    if (!assetManager._shouldProcessPage(page)) {
      return nodes;
    }

    return _processNodes(nodes, page);
  }

  List<Node> _processNodes(List<Node> nodes, Page page) {
    const targetElements = {
      'img': 'src',
      'video': 'src',
      'audio': 'src',
      'source': 'src',
    };
    return nodes.map((node) {
      if (node is! ElementNode) return node;
      final tag = node.tag.toLowerCase();
      if (targetElements[tag] case final attribute?) {
        final assetPath = node.attributes[attribute];
        if (assetPath != null) {
          return ElementNode(node.tag, {
            ...node.attributes,
            attribute: assetManager.resolveAsset(assetPath, page),
          }, node.children);
        }
      }
      if (node.children case final children?) {
        return ElementNode(
          node.tag,
          node.attributes,
          _processNodes(children, page),
        );
      }
      return node;
    }).toList();
  }
}
