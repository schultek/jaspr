import 'package:http/http.dart' as http;
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/html.dart';
import '../main.container.dart';
import '../models/api_models.dart';
import '../models/sample.dart';
import '../models/tutorial.dart';

final dartServiceProvider = Provider((ref) => DartService(ref));

class DartService {
  DartService(this.ref);

  final Ref ref;
  final client = http.Client();

  Future<FormatResponse> format(String source) => _request('format', FormatRequest(source, 0));

  Future<AnalyzeResponse> analyze(Map<String, String> sources) => _request('analyze', AnalyzeRequest(sources));

  Future<CompileResponse> compile(Map<String, String> sources) => _request('compile', CompileRequest(sources));

  Future<DocumentResponse> document(Map<String, String> sources, String name, int offset) =>
      _request('document', DocumentRequest(sources, name, offset));

  Future<SampleResponse> getSample(String id) => _get('sample/$id');
  Future<TutorialResponse> getTutorial(String id) => _get('tutorial/$id');

  Future<T> _get<T>(String path) async {
    var response = await client.get(Uri.parse('${window.location.origin}/api/$path'));
    return mainContainer.fromJson<T>(response.body);
  }

  Future<T> _request<T>(String action, Object body) async {
    var response =
        await client.post(Uri.parse('${window.location.origin}/api/$action'), body: mainContainer.toJson(body));
    return mainContainer.fromJson<T>(response.body);
  }
}
