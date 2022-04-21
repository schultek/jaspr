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

  Future<FormatResponse> format(String source) => _request('format', {'source': source});

  Future<AnalyzeResponse> analyze(String source) => _request(
      'analyze',
      {
        'sources': {'main.dart': source}
      },
      url: '${window.location.origin}/api');

  Future<CompileResponse> compile(Map<String, String> sources) =>
      _request('compile', CompileRequest(sources), url: '${window.location.origin}/api');

  Future<T> _request<T>(String action, Object body, {String? url}) async {
    var response =
        await client.post(Uri.parse('${url ?? ref.read(serviceUrlProvider)}/$action'), body: Mapper.toJson(body));
    return Mapper.fromJson<T>(response.body);
  }
}
