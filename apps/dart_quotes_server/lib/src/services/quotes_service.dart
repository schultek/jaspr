import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class QuotesService {
  static Future<List<Quote>> loadQuotes(Session session) async {
    var quotes = await Quote.db.find(session);
    return quotes;
  }

  static Future<Quote?> getQuoteById(Session session, int id) async {
    var quote = await Quote.db.findById(session, id);
    return quote;
  }

  static Future<Quote?> toggleLikeOnQuote(Session session, int id, bool liked) async {
    var userId = await session.auth.authenticatedUserId ?? 2;
    if (userId == null) return null;

    var quote = await getQuoteById(session, id);
    if (quote == null) return null;

    quote.likes.remove(userId);
    if (liked) {
      quote.likes.add(userId);
    }

    await Quote.db.updateRow(session, quote);
    return quote;
  }
}
