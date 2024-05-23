import 'package:dart_quotes_client/dart_quotes_client.dart' if (dart.library.io) '../../src/generated/protocol.dart'
    show Quote;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_serverpod/jaspr_serverpod.dart';

@Import.onWeb('package:dart_quotes_client/dart_quotes_client.dart',
    show: [#StreamingConnectionHandler, #Client, #QuoteInit])
@Import.onWeb('../interop/confetti.dart', show: [#JSConfetti])
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

  late final ClientOrStubbed client = Client('http://localhost:8080/');

  int count = 0;
  bool? hasLiked;

  @override
  void initState() {
    super.initState();

    count = component.initialCount;

    if (kIsWeb) {
      client.connectivityMonitor = JasprConnectivityMonitor();

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
  }

  Future<void> _listenToUpdates() async {
    await for (var update in client.quotes.stream) {
      if (update is Quote) {
        setState(() {
          count = update.likes.length;
          hasLiked = update.likes.contains(2);
        });
      }
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
      classes: "quote-like-btn${hasLiked == true ? ' active' : ''}",
      onClick: () {
        if (hasLiked == null) return;

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

  static List<StyleRule> get styles => [
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
