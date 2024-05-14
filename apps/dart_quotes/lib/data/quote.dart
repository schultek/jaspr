class Quote {
  final String id;
  final String quote;
  final String author;
  final List<String> likes;

  Quote({required this.id, required this.quote, required this.author, required this.likes});

  Quote.fromData(this.id, Map<String, dynamic> data)
      : quote = data['quote'] as String,
        author = data['author'] as String,
        likes = (data['likes'] as List).cast();
}
