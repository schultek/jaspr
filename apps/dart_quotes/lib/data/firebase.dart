import 'dart:io';

import 'package:jaspr/jaspr.dart';

@Import.onWeb('package:firebase_core/firebase_core.dart', show: [#Firebase, #FirebaseApp])
@Import.onWeb('package:cloud_firestore/cloud_firestore.dart',
    show: [#FirebaseFirestore, #FieldValue, #DocumentSnapshot])
@Import.onWeb('package:firebase_auth/firebase_auth.dart', show: [#FirebaseAuth])
@Import.onWeb('../firebase_options.dart', show: [#DefaultFirebaseOptions])
@Import.onServer('package:dart_firebase_admin/dart_firebase_admin.dart', show: [#FirebaseAdminApp, #Credential])
@Import.onServer('package:dart_firebase_admin/firestore.dart', show: [#Firestore])
import 'firebase.imports.dart';
import 'quote.dart';

class FirebaseService {
  static FirebaseService instance = FirebaseService();

  // === server setup ===

  late final FirebaseAdminAppOrStubbed adminApp = FirebaseAdminApp.initializeApp(
    'dart-quotes',
    Credential.fromServiceAccount(File('service-account.json')),
  );

  late final FirestoreOrStubbed adminFirestore = Firestore(adminApp);

  // === client logic ===

  late final Future<FirebaseAppOrStubbed> clientApp = Future(() async {
    var app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAuth.instance.signInAnonymously();

    return app;
  });

  Future<List<Quote>> loadQuotes() async {
    if (kIsWeb) {
      throw UnimplementedError("[loadQuotes] is not implemented on the client.");
    }

    var query = await adminFirestore.collection('quotes').get();
    return query.docs.map((doc) {
      return Quote.fromData(doc.id, doc.data());
    }).toList();
  }

  Stream<Quote?> getQuoteById(String id) async* {
    if (kIsWeb) {
      await clientApp;
      var snapshots = FirebaseFirestore.instance.collection('quotes').doc(id).snapshots();
      await for (var doc in snapshots) {
        yield Quote.fromData(doc.id, doc.data()!);
      }
    } else {
      var doc = await adminFirestore.doc('quotes/$id').get();
      if (doc.exists) {
        yield Quote.fromData(doc.id, doc.data()!);
      } else {
        yield null;
      }
    }
  }

  Future<void> toggleLikeOnQuote(String id, bool liked) async {
    if (!kIsWeb) {
      throw UnimplementedError("[toggleLikeOnQuote] is not implemented on the server.");
    }

    await clientApp;
    var userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('quotes').doc(id).update({
      'likes': liked ? FieldValue.arrayUnion([userId]) : FieldValue.arrayRemove([userId]),
    });
  }

  String getUserId() {
    if (!kIsWeb) {
      throw UnimplementedError("[getUserId] is not implemented on the server.");
    }

    return FirebaseAuth.instance.currentUser!.uid;
  }
}
