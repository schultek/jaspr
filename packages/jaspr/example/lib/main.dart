import 'package:jaspr/jaspr.dart';

import 'app.dart';
import 'services/service.dart';

class ServerDataService implements DataService {
  @override
  Future<int> getData() async {
    return 500;
  }
}

void main() {
  runApp(Builder.single(builder: (context) {
    DataService.instance = ServerDataService();
    return App();
  }));
}
