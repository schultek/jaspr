import 'dart:io';

import 'package:dart_quotes/data/quote.dart';
import 'package:jaspr/jaspr.dart';

@Import.onWeb('package:firebase_core/firebase_core.dart', show: [#Firebase])
@Import.onWeb('package:cloud_firestore/cloud_firestore.dart',
    show: [#FirebaseFirestore, #FieldValue, #DocumentSnapshot])
@Import.onWeb('package:firebase_auth/firebase_auth.dart', show: [#FirebaseAuth])
@Import.onWeb('../firebase_options.dart', show: [#DefaultFirebaseOptions])
@Import.onServer('package:dart_firebase_admin/dart_firebase_admin.dart', show: [#FirebaseAdminApp, #Credential])
@Import.onServer('package:dart_firebase_admin/firestore.dart', show: [#Firestore])
import 'firebase.imports.dart';

// === server logic ===

final admin = FirebaseAdminApp.initializeApp(
  'dart-quotes',
  Credential.fromServiceAccount(File('service-account.json')),
);
final firestore = Firestore(admin);

Future<List<Quote>> loadQuotes() async {
  var query = await firestore.collection('quotes').get();

  return query.docs.map((doc) => Quote.fromData(doc.id, doc.data())).toList();
}

Future<Quote?> loadQuoteById(String id) async {
  var doc = await firestore.doc('quotes/$id').get();
  if (!doc.exists) {
    return null;
  }

  return Quote.fromData(doc.id, doc.data()!);
}

// === client logic ===
final initializeApp = Future(() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAuth.instance.signInAnonymously();
});

Future<void> toggleLikeOnQuote(String id, bool liked) async {
  await initializeApp;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('quotes').doc(id).update({
    'likes': liked ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
  });
}

String getUserId() {
  if (!kIsWeb) throw UnsupportedError("UserId only available on client.");
  return FirebaseAuth.instance.currentUser!.uid;
}

Stream<Quote> getQuoteStream(String id) async* {
  await initializeApp;
  var snapshots = FirebaseFirestore.instance.collection('quotes').doc(id).snapshots();
  await for (var doc in snapshots) {
    yield Quote.fromData(doc.id, doc.data()!);
  }
}
