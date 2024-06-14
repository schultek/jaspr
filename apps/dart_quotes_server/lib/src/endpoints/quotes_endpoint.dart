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

  @override
  Future<void> handleStreamMessage(
    StreamingSession session,
    SerializableModel message,
  ) async {
    if (message is QuoteInit) {
      var quote = await QuotesService.getQuoteById(session, message.id);
      if (quote == null) return;

      sendStreamMessage(session, quote);

      session.messages.addListener('quote-update-${message.id}', (update) {
        sendStreamMessage(session, update);
      });
    }
  }
}
