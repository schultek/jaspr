import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Counter extends StatefulComponent {
  const Counter({super.key});

  @override
  State<Counter> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  SharedPreferences? store;
  DocumentReference<Map<String, dynamic>>? countDoc;
  int _remoteCount = 0;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() => store = prefs);
    });

    initFirestore();
  }

  Future<void> initFirestore() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBWFqH6yhMamn40w2Y5ln1mpgCJQoWgOcs",
        authDomain: "jaspr-demo.firebaseapp.com",
        projectId: "jaspr-demo",
        storageBucket: "jaspr-demo.appspot.com",
        messagingSenderId: "1022309922786",
        appId: "1:1022309922786:web:57753e5507fd58cb656bbb",
      ),
    );

    await FirebaseAuth.instance.signInAnonymously();

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
  Component build(BuildContext context) {
    return div(classes: 'container', [
      button(events: {'click': (_) => setState(() => count++)}, [.text('Local count: $count')]),
      button(events: {'click': (_) => setState(() => remoteCount++)}, [.text('Firestore count: $remoteCount')]),
    ]);
  }
}
