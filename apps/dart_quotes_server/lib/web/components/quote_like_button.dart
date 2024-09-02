import 'package:dart_quotes_client/dart_quotes_client.dart' if (dart.library.io) '../../src/generated/protocol.dart'
    show Quote;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';

@Import.onWeb('package:dart_quotes_client/dart_quotes_client.dart',
    show: [#StreamingConnectionHandler, #Client, #QuoteInit])
@Import.onWeb('package:serverpod_auth_shared_flutter/serverpod_auth_shared_flutter.dart',
    show: [#FlutterAuthenticationKeyManager, #SessionManager])
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
  late final StreamingConnectionHandlerOrStubbed connectionHandler;

  late final ClientOrStubbed client = Client(
    'http://localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  );
  late SessionManagerOrStubbed sessionManager;

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
    sessionManager = SessionManager(
      caller: client.modules.auth,
    );
    await sessionManager.initialize();

    // Start listening to updates from the quotes endpoint.
    _listenToUpdates();

    // Setup our connection handler and open a streaming connection to the
    // server. The [StreamingConnectionHandler] will attempt to reconnect until
    // the `close` method is called.
    connectionHandler = StreamingConnectionHandler(
      client: client,
      listener: (connectionState) {
        if (connectionState.status.index == 0) {
          client.quotes.sendStreamMessage(QuoteInit(id: component.id));
        }
        setState(() {});
      },
    );
    connectionHandler.connect();
  }

  Future<void> _listenToUpdates() async {
    await for (var update in client.quotes.stream) {
      if (update is Quote) {
        setState(() {
          count = update.likes.length;
          hasLiked = sessionManager.isSignedIn && update.likes.contains(sessionManager.signedInUser?.id);
        });
      }
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
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
      [
        span(classes: "icon-heart${hasLiked ?? false ? '' : '-o'}", []),
        text(' $count'),
      ],
    );
  }

  @css
  static final styles = [
    css('.quote-like-btn', [
      css('&')
          .box(border: Border.all(BorderSide.none()), outline: Outline(style: OutlineStyle.none))
          .background(color: Colors.transparent)
          .text(fontSize: 18.px),
      css('&:hover span').box(transform: Transform.scale(1.2)),
      css('&.active span').text(color: Colors.blue),
      css('span').raw({'transition': 'transform 300ms ease'}),
    ])
  ];
}
