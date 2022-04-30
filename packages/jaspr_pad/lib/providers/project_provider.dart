import 'package:http/http.dart' as http;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/html.dart';
import '../components/elements/snackbar.dart';
import '../main.mapper.g.dart';
import '../models/gist.dart';
import '../models/project.dart';
import 'dart_service_provider.dart';

final fetchedProjectProvider = FutureProvider.family((ref, String id) async {
  try {
    var response = await http.get(Uri.parse('https://api.github.com/gists/$id'));
    if (response.statusCode == 404) throw 'Gist does not exist';
    if (response.statusCode != 200) throw 'Unknown error ${response.statusCode}';

    var gist = Mapper.fromJson<GistData>(response.body);
    return ProjectData.fromGist(gist);
  } catch (e) {
    ref.read(snackBarProvider.notifier).state = 'Error loading gist $id: $e.';
    return null;
  }
});

final fetchedSampleProvider = FutureProvider.family((ref, String id) async {
  try {
    var project = await ref.read(dartServiceProvider).getSample(id);
    if (project.project != null) {
      return project.project!;
    } else {
      throw project.error!;
    }
  } catch (e) {
    ref.read(snackBarProvider.notifier).state = 'Error loading sample $id: $e.';
    return null;
  }
});

final storageProvider = Provider((ref) => window.localStorage);

final storedProjectProvider = Provider.autoDispose((ref) {
  return window.localStorage.containsKey('project') //
      ? Mapper.fromJson<ProjectData>(window.localStorage['project']!)
      : null;
});

final selectedSampleProvider = StateProvider<ProjectData?>((ref) => null);

final loadedProjectProvider = Provider<AsyncValue<ProjectData>>((ref) {
  if (!kIsWeb) {
    return AsyncValue.loading(); // Don't load on server
  }
  var storedProject = ref.read(storedProjectProvider);
  if (storedProject != null) {
    return AsyncValue.data(storedProject);
  } else {
    var uri = ComponentsBinding.instance!.currentUri;
    var gistId = uri.queryParameters['gist'];
    var sampleId = uri.queryParameters['sample'];

    AsyncValue<ProjectData?> project;

    if (gistId != null) {
      project = ref.watch(fetchedProjectProvider(gistId));
    } else if (sampleId != null) {
      project = ref.watch(fetchedSampleProvider(sampleId));
    } else {
      project = AsyncValue.data(createDefaultProject());
    }

    return project.whenData((project) => project?.copyWith() ?? createDefaultProject());
  }
});

final projectNameProvider = Provider<String?>((ref) => ref.watch(loadedProjectProvider).value?.description);

ProjectData createDefaultProject() {
  return ProjectData(
    id: 'basic',
    description: 'jaspr_basic',
    cssFile: 'html, body {\n'
        '  display: flex;\n'
        '  justify-content: center;\n'
        '  align-items: center;\n'
        '  height: 100%;\n'
        '  color: white;\n'
        '  font-family: sans-serif;\n'
        '}',
    mainDartFile: "import 'package:jaspr/jaspr.dart';\n\n"
        "void main() {\n"
        "  runApp(DomComponent(\n"
        "    tag: 'h1',\n"
        "    child: Text('Hello World!'),\n"
        "  ));\n"
        "}",
  );
}
