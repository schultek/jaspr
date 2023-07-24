import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jaspr/html.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A simple [StatelessComponent] with a [build] method
class App extends StatefulComponent {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  SharedPreferences? store;
  DocumentReference<Map<String, dynamic>>? countDoc;
  int _remoteCount = 0;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((s) {
      setState(() => store = s);
    });

    var userId = FirebaseAuth.instance.currentUser?.uid;
    countDoc = FirebaseFirestore.instance.doc('counts/$userId');
    countDoc!.snapshots().listen((event) {
      setState(() => _remoteCount = event.data()?['count'] ?? 0);
    });
  }

  int get count => store?.getInt('count') ?? 0;
  set count(int c) => store?.setInt('count', c);

  int get remoteCount => _remoteCount;
  set remoteCount(int c) {
    countDoc?.set({'count': c});
    _remoteCount = c;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: [
      'container'
    ], [
      button(events: {'click': (_) => setState(() => count++)}, [text('Local count: $count')]),
      button(events: {'click': (_) => setState(() => remoteCount++)}, [text('Firestore count: $remoteCount')]),
    ]);
  }
}
