import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../page.dart';
import 'page_loader.dart';

/// A loader that loads pages from a github repository.
/// 
/// Routes are constructed based on the recursive folder structure starting at the root [path].
/// Index files (index.*) are treated as the page for the containing folder.
/// Files and folders starting with an underscore (_) are ignored.
class GithubLoader extends PageLoaderBase {
  GithubLoader(
    this.repo, {
    this.ref = 'main',
    this.path = 'docs',
    this.accessToken,
    super.eager,
    super.debugPrint,
  });

  /// The repository to load pages from. Must be in the form '<owner>/<repo>'.
  final String repo;
  /// The branch, tag or commit to checkout the repository at.
  final String ref;
  /// The root path to load pages from.
  final String path;

  /// The access token to use for authentication.
  /// 
  /// This is required for private repositories. 
  /// For public repositories you may quickly hit rate limits without an access token.
  final String? accessToken;

  @override
  Future<String> readPartial(String path, Page page) {
    throw UnsupportedError('Reading partial files is not supported for GithubLoader');
  }
  
  @override
  String readPartialSync(String path, Page page) {
   throw UnsupportedError('Reading partial files is not supported for GithubLoader');
  }

  @override
  PageFactory createFactory(PageRoute page, PageConfig config) {
    return GithubPageFactory(page,config, this);
  }

  Future<List<dynamic>> _loadTree() async {
    var response = await http.get(
      Uri.parse('https://api.github.com/repos/$repo/git/trees/$ref?recursive=true'),
      headers: {
        'Accept': 'application/vnd.github+json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        'X-GitHub-Api-Version': '2022-11-28',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load tree: ${response.statusCode} - ${response.body}');
    }
    var files = jsonDecode(response.body)['tree'] as List;
    return files;
  }

  @override
  Future<List<PageEntity>> loadPageEntities() async {
    final root = path;
    var files = await _loadTree();

    Map<String, dynamic> tree = {};

    for (final file in files) {
      if (file['type'] != 'blob') continue;
      var path = file['path'];

      if (!file['path'].startsWith(root)) continue;
      path = path.substring(root.length);
      if (path.startsWith('/')) path = path.substring(1);
      if (path.isEmpty) continue;

      var segments = path.split('/');

      var current = tree;
      for (var i = 0; i < segments.length - 1; i++) {
        var segment = segments[i];
        current = (current[segment] ??= <String, dynamic>{});
      }
      current[segments.last] = PageSource(segments.last, file['url']);
    }

    PageEntity? getEntity(MapEntry<String, dynamic> entry) {
      if (entry.value case PageSource file) {
        return file;
      } else if (entry.value case Map<String, dynamic> map) {
        return PageCollection(entry.key, map.entries.map(getEntity).whereType<PageEntity>().toList());
      } else {
        return null;
      }
    }

    return tree.entries.map(getEntity).whereType<PageEntity>().toList();
  }
  
}

class GithubPageFactory extends PageFactory<GithubLoader> {
  GithubPageFactory(super.route,super.config, super.loader);

  @override
  Future<Page> buildPage() async {
    final response = await http.get(Uri.parse(route.source), headers: {
      'Accept': 'application/vnd.github.raw+json',
      if (loader.accessToken != null) 'Authorization': 'Bearer ${loader.accessToken}',
      'X-GitHub-Api-Version': '2022-11-28',
    });
    final content = response.body;
    final data = {
      'page': {'url': route.route},
    };

    return Page(route.name, route.route, content, data, config, loader);
  }
}
