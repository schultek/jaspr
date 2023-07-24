//import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
//import 'package:firebase_auth_web/firebase_auth_web.dart';
//import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
//import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_plugin_interop/app.dart';
import 'package:flutter_plugin_interop/web_plugin_registrant.dart';
import 'package:jaspr/browser.dart';

void main() async {
  registerPlugins();

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

  runApp(App());
}
