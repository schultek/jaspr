import 'package:dart_mappable/dart_mappable.dart';
import 'package:http/http.dart' as http;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/html.dart';
import '../main.mapper.g.dart';

final fetchedGistProvider = FutureProvider.family((ref, String id) async {
  var response = await http.get(Uri.parse('https://api.github.com/gists/$id'));
  if (response.statusCode == 200) {
    return Mapper.fromJson<GistData>(response.body);
  } else {
    return null;
  }
});

final storageProvider = Provider((ref) => window.localStorage);

final storedGistProvider = Provider.autoDispose((ref) {
  return window.localStorage.containsKey('gist') //
      ? Mapper.fromJson<GistData>(window.localStorage['gist']!)
      : null;
});

final gistProvider = Provider<AsyncValue<GistData>>((ref) {
  if (!kIsWeb) {
    return AsyncValue.loading(); // Don't load on server
  }
  var uri = ComponentsBinding.instance!.currentUri;
  var id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  var storedGist = ref.read(storedGistProvider);
  if (storedGist != null && storedGist.id == id) {
    return AsyncValue.data(storedGist);
  } else if (id != null) {
    return ref.watch(fetchedGistProvider(id)).whenData((gist) => gist?.copyWith() ?? createDartGist());
  } else {
    return AsyncValue.data(createDartGist());
  }
});

final gistNameProvider = Provider<String?>((ref) => ref.watch(gistProvider).value?.description);

GistData createDartGist() {
  return GistData(null, null, {
    'main.dart': GistFile(
        'Dart',
        "import 'package:jaspr/jaspr.dart';\n\nvoid main() {\n  runApp(() => DomComponent(\n    tag: 'h1',\n    child: Text('Hello World!'),\n  ), id: 'app');\n}",
        'application/vnd.dart'),
    'index.html': GistFile('HTML', '<div id="app"></div>', 'text/html'),
    'styles.css': GistFile(
        'CSS',
        'html, body {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n  height: 100%;\n}\n\ndiv {\n  color: white;\n  font-family: sans-serif;\n}',
        'text/css'),
  });
}

@MappableClass()
class GistData {
  final String? id;
  final String? description;
  final Map<String, GistFile> files;

  GistData(this.id, this.description, this.files);
}

@MappableClass()
class GistFile {
  @MappableField(key: 'filename')
  String name;
  String content;
  String type;

  GistFile(this.name, this.content, this.type);
}
