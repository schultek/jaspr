import 'package:dart_web/dart_web.dart';

import 'app.dart';
import 'services/service.dart';

class ServerDataService implements DataService {
  @override
  Future<int> getData() async {
    return 500;
  }
}

void main() {
  runApp(() {
    // create a service instance
    DataService.instance = ServerDataService();

    // provide an entry component and an id to attach it to
    return App();
  }, id: 'app');
}
