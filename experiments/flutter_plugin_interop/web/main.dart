//import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
//import 'package:firebase_auth_web/firebase_auth_web.dart';
//import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
//import 'package:firebase_core_web/firebase_core_web.dart';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_web/firebase_auth_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_plugin_interop/app.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:jaspr/browser.dart';
import 'package:shared_preferences_web/shared_preferences_web.dart';

void main() async {
  var registrar = Registrar();
  SharedPreferencesPlugin.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FirebaseAuthWeb.registerWith(registrar);

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD4KcAJm36g-Dy5pXWS5GiORn1ErUdtLVg",
      authDomain: "jufa20.firebaseapp.com",
      databaseURL: "https://jufa20.firebaseio.com",
      projectId: "jufa20",
      storageBucket: "jufa20.appspot.com",
      messagingSenderId: "815326157809",
      appId: "1:815326157809:web:f4d9f3ed08450480d3c250",
      measurementId: "G-MQVZXXJ542",
    ),
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    print(user);
    if (user != null) {
      print(user.uid);
    }
  });

  print(ui.Color(1));

  runApp(App());
}
