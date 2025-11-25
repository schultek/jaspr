import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';

@Import.onWeb(
  'package:dart_quotes_client/dart_quotes_client.dart',
  show: [#StreamingConnectionHandler, #Client, #QuoteInit],
)
@Import.onWeb(
  'package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart',
  show: [#FlutterAuthenticationKeyManager, #SessionManager],
)
@Import.onWeb('../interop/confetti.dart', show: [#JSConfetti])
@Import.onWeb('package:serverpod_auth_google_flutter/serverpod_auth_google_flutter.dart', show: [#signInWithGoogle])
import 'quote_like_button.imports.dart';

@client
class QuoteLikeButton extends StatefulComponent {
  const QuoteLikeButton({required this.id, required this.initialCount});

  final int id;
  final int initialCount;

  @override
  State<StatefulComponent> createState() => QuoteLikeButtonState();
}

class QuoteLikeButtonState extends State<QuoteLikeButton> {
  late final ClientOrStubbed client = Client(
    'http://localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  );
  late SessionManagerOrStubbed sessionManager;

  StreamSubscription? subscription;

  int count = 0;
  bool? hasLiked;

  @override
  void initState() {
    super.initState();

    count = component.initialCount;

    if (kIsWeb) {
      initStateWeb();
    }
  }

  Future<void> initStateWeb() async {
    client.connectivityMonitor = JasprConnectivityMonitor();

    // The session manager keeps track of the signed-in state of the user. You
    // can query it to see if the user is currently signed in and get information
    // about the user.
    sessionManager = SessionManager(caller: client.modules.auth);
    await sessionManager.initialize();

    subscription = client.quotes.subscribeToQuote(component.id).listen((quote) {
      setState(() {
        count = quote.likes.length;
        hasLiked = sessionManager.isSignedIn && quote.likes.contains(sessionManager.signedInUser?.id);
      });
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: "quote-like-btn${hasLiked == true ? ' active' : ''}",
      onClick: () async {
        if (hasLiked == null) return;

        if (!sessionManager.isSignedIn) {
          var user = await signInWithGoogle(
            client.modules.auth,
            debug: true,
            serverClientId: "115506349548-85ujf55vmejrg7idb3vfmbm7ee5lg5uk.apps.googleusercontent.com",
            redirectUri: Uri.parse('http://localhost:8082/googlesignin'),
          );

          if (user == null) {
            return;
          }
        }

        client.quotes.toggleLikeOnQuote(component.id, !hasLiked!);
        if (!hasLiked!) {
          JSConfetti.instance.show(emojis: ['🎯', '💙']);
        }
      },
      [span(classes: "icon-heart${hasLiked ?? false ? '' : '-o'}", []), .text(' $count')],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.quote-like-btn', [
      css('&').styles(
        border: .none,
        outline: .new(style: .none),
        fontSize: 18.px,
        backgroundColor: Colors.transparent,
      ),
      css('&:hover span').styles(transform: .scale(1.2)),
      css('&.active span').styles(color: Colors.blue),
      css('span').styles(
        transition: .new('transform', duration: 300.ms, curve: .ease),
      ),
    ]),
  ];
}
