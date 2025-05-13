import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../page.dart';
import 'route_loader.dart';

/// A loader that loads routes from a github repository.
///
/// Routes are constructed based on the recursive folder structure starting at the root [path].
/// Index files (index.*) are treated as the page for the containing folder.
/// Files and folders starting with an underscore (_) are ignored.
class GithubLoader extends RouteLoaderBase {
  GithubLoader(
    this.repo, {
    this.ref = 'main',
    this.path = 'docs/',
    this.keeySuffixPattern,
    this.accessToken,
    super.debugPrint,
  });

  /// The repository to load pages from. Must be in the form `'<owner>/<repo>'`.
  final String repo;

  /// The branch, tag or commit to checkout the repository at.
  final String ref;

  /// The root path to load pages from.
  final String path;

  /// A pattern to keep the file suffix for all matching pages.
  final Pattern? keeySuffixPattern;

  /// The access token to use for authentication.
  ///
  /// This is required for private repositories.
  /// For public repositories you may quickly hit rate limits without an access token.
  final String? accessToken;

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
  Future<List<PageSource>> loadPageSources() async {
    var root = path;
    if (root.isNotEmpty && !root.endsWith('/')) {
      root += '/';
    }
    var files = await _loadTree();

    List<PageSource> routes = [];

    for (final file in files) {
      if (file['type'] != 'blob') continue;
      var path = file['path'];

      if (!file['path'].startsWith(root)) continue;
      path = path.substring(root.length);
      if (path.startsWith('/')) path = path.substring(1);
      if (path.isEmpty) continue;

      routes.add(GithubPageSource(
        path,
        file['url'],
        this,
        accessToken: accessToken,
        keepSuffix: keeySuffixPattern?.matchAsPrefix(path) != null,
      ));
    }

    return routes;
  }
}

class GithubPageSource extends PageSource {
  GithubPageSource(super.path, this.blobUrl, super.loader, {this.accessToken, super.keepSuffix = false});

  final String blobUrl;
  final String? accessToken;

  @override
  Future<Page> buildPage() async {
    final response = await http.get(Uri.parse(blobUrl), headers: {
      'Accept': 'application/vnd.github.raw+json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      'X-GitHub-Api-Version': '2022-11-28',
    });
    final content = response.body;

    return Page(
      path: path,
      url: url,
      content: content,
      data: {},
      config: config,
      loader: loader,
    );
  }
}
