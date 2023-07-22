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

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((s) => store = s);
  }

  int get count => store?.getInt('count') ?? 0;
  set count(int c) => store?.setInt('count', c);

  @override
  Iterable<Component> build(BuildContext context) sync* {
    // renders a <p> element with 'Hello World' content
    yield DomComponent(
      tag: 'button',
      events: {
        'click': (_) {
          print("CLICKED");
          setState(() {
            count++;
          });
        }
      },
      child: Text('Count: $count'),
    );

    yield button(
      [text('Login')],
      events: {
        'click': (_) {
          FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'kilian@test.de',
            password: '1234test',
          );
        }
      },
    );
  }
}
