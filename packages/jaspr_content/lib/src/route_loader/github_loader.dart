import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http show get;

import '../page.dart';
import 'route_loader.dart';

@Deprecated('Migrate to GitHubLoader instead.')
typedef GithubLoader = GitHubLoader;

/// A loader that loads routes from a GitHub repository.
///
/// Routes are constructed based on the recursive folder structure starting at the root [path].
/// Index files (index.*) are treated as the page for the containing folder.
/// Files and folders starting with an underscore (_) are ignored.
class GitHubLoader extends RouteLoaderBase {
  GitHubLoader(
    this.repo, {
    this.ref = 'main',
    this.path = 'docs/',
    this.keepSuffixPattern,
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
  final Pattern? keepSuffixPattern;

  /// The access token to use for authentication.
  ///
  /// This is required for private repositories.
  /// For public repositories you may quickly hit rate limits without an access token.
  final String? accessToken;

  Future<List<_GitHubTree>> _loadTree() async {
    final response = await http.get(
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
    final decodedJson = jsonDecode(response.body) as Map<String, Object?>;
    final files = decodedJson['tree'] as List<Object?>;
    return files.cast<_GitHubTree>();
  }

  @override
  Future<List<PageSource>> loadPageSources() async {
    var root = path;
    if (root.isNotEmpty && !root.endsWith('/')) {
      root += '/';
    }

    final files = await _loadTree();
    final routes = <PageSource>[];
    for (final file in files) {
      final fileUrl = file.url;
      if (file.type != 'blob' || fileUrl == null) continue;
      var path = file.path;

      if (!path.startsWith(root)) continue;
      path = path.substring(root.length);
      if (path.startsWith('/')) path = path.substring(1);
      if (path.isEmpty) continue;

      routes.add(_GitHubPageSource(
        path,
        fileUrl,
        this,
        accessToken: accessToken,
        keepSuffix: keepSuffixPattern?.matchAsPrefix(path) != null,
      ));
    }

    return routes;
  }
}

/// A Git tree returned from the GitHub REST API.
///
/// For more information on the structure,
/// reference https://docs.github.com/en/rest/git/trees?apiVersion=2022-11-28.
extension type _GitHubTree._(Map<String, Object?> tree) {
  String get path => tree['path'] as String;
  String get type => tree['type'] as String;
  String? get url => tree['url'] as String?;
  String get sha => tree['sha'] as String;
}

class _GitHubPageSource extends PageSource {
  _GitHubPageSource(
    super.path,
    this.blobUrl,
    super.loader, {
    this.accessToken,
    super.keepSuffix = false,
  });

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
      config: config,
      loader: loader,
    );
  }
}
