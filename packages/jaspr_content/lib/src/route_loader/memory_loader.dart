import '../page.dart';
import 'route_loader.dart';

/// A loader that loads routes from memory.
///
/// Takes a list of [MemoryPage]s and creates routes from them.
class MemoryLoader extends RouteLoaderBase {
  MemoryLoader({required List<MemoryPage> pages,  super.debugPrint}) : _pages = pages;

  final List<MemoryPage> _pages;

  @override
  PageFactory createFactory(PageRoute route, PageConfig config) {
    final page = _pages.where((p) => p.path == route.path).first;
    return MemoryPageFactory(page, route, config, this);
  }

  @override
  Future<List<RouteEntity>> loadPageEntities() async {
    final entities = <RouteEntity>[];
    for (final page in _pages) {
      entities.add(SourceRoute(page.path, page.path, keepSuffix: true));
    }
    return entities;
  }

  @override
  Future<String> readPartial(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for MemoryLoader');
  }

  @override
  String readPartialSync(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for MemoryLoader');
  }
}

class MemoryPage {
  const MemoryPage({
    required this.path,
    required this.content,
    this.data = const {},
  });

  final String path;
  final String content;
  final Map<String, dynamic> data;
}

class MemoryPageFactory extends PageFactory {
  MemoryPageFactory(this._page, super.route, super.config, super.loader);

  final MemoryPage _page;

  @override
  Future<Page> buildPage() async {
    return Page(route.path, route.route, _page.content, _page.data, config, loader);
  }
}
