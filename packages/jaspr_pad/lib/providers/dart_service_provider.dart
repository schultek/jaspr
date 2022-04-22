import 'package:http/http.dart' as http;
import 'package:jaspr_pad/models/api_models.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

import '../adapters/html.dart';
import '../main.mapper.g.dart';

final serviceUrlProvider = Provider((ref) => 'https://stable.api.dartpad.dev/api/dartservices/v2');

final dartServiceProvider = Provider((ref) => DartService(ref));

class DartService {
  DartService(this.ref);

  final Ref ref;
  final client = http.Client();

  Future<FormatResponse> format(String source) => _request('format', FormatRequest(source, 0));

  Future<AnalyzeResponse> analyze(String source) => _request('analyze', AnalyzeRequest({'main.dart': source}));

  Future<CompileResponse> compile(Map<String, String> sources) => _request('compile', CompileRequest(sources));

  Future<DocumentResponse> document(String source, int offset) => _request('document', DocumentRequest(source, offset));

  Future<T> _request<T>(String action, Object body) async {
    var response = await client.post(Uri.parse('${window.location.origin}/api/$action'), body: Mapper.toJson(body));
    return Mapper.fromJson<T>(response.body);
  }
}
