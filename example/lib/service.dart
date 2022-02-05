// example service
abstract class DataService {
  // better to use a service locator, this is just for demo purposes
  static DataService? instance;

  Future<int> getData();
}
