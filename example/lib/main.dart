import 'package:dart_web/dart_web.dart';
import 'package:domino_test/service.dart';

import 'components/app.dart';

class ServerDataService implements DataService {
  @override
  Future<int> getData() async {
    return 102;
  }
}

void main() {
  // create a service instance
  DataService.instance = ServerDataService();

  // provide an entry component and an id to attach it to
  runApp(App(), id: 'app');
}
