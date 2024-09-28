import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/quotes_service.dart';

class QuotesEndpoint extends Endpoint {
  Future<void> toggleLikeOnQuote(Session session, int id, bool liked) async {
    var quote = await QuotesService.toggleLikeOnQuote(session, id, liked);
    if (quote != null) {
      session.messages.postMessage('quote-update-${quote.id}', quote, global: false);
    }
  }

  Stream<Quote> subscribeToQuote(Session session, int id) async* {
    var quote = await QuotesService.getQuoteById(session, id);
    if (quote == null) return;

    yield quote;
    yield* session.messages.createStream('quote-update-${id}');
  }
}
