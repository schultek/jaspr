class ShowcaseItem {
  final String title;
  final String url;
  final String displayUrl;
  final String category;
  final String image;

  const ShowcaseItem({
    required this.title,
    required this.url,
    required this.displayUrl,
    required this.category,
    required this.image,
  });

  factory ShowcaseItem.fromMap(Map<String, Object?> map) {
    final title = map['title']?.toString() ?? 'Showcase';
    final url = map['url']?.toString() ?? '';
    final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    final image = map['image']?.toString() ?? 'images/showcase/$slug.png';
    final rawDisplayUrl = map['displayUrl']?.toString();
    final displayUrl = (rawDisplayUrl != null && rawDisplayUrl.isNotEmpty)
        ? rawDisplayUrl
        : url.replaceFirst(RegExp(r'^https?:\/\/'), '').replaceAll(RegExp(r'\/$'), '');

    return ShowcaseItem(
      title: title,
      url: url,
      displayUrl: displayUrl,
      category: map['category']?.toString() ?? 'Project',
      image: image,
    );
  }

  static List<ShowcaseItem> fromData(Object? data) {
    if (data is List && data.isNotEmpty) {
      return [
        for (final item in data)
          if (item is Map) ShowcaseItem.fromMap(item.cast<String, Object?>()),
      ];
    }
    return defaultShowcaseItems;
  }
}

const defaultShowcaseItems = <ShowcaseItem>[
  ShowcaseItem(
    title: 'Flutter Website',
    url: 'https://flutter.dev',
    displayUrl: 'flutter.dev',
    category: 'Official & Docs',
    image: 'images/showcase/flutter_dev.png',
  ),
  ShowcaseItem(
    title: 'Dart Website',
    url: 'https://dart.dev',
    displayUrl: 'dart.dev',
    category: 'Official & Docs',
    image: 'images/showcase/dart_dev.png',
  ),
  ShowcaseItem(
    title: 'Flutter Documentation',
    url: 'https://docs.flutter.dev',
    displayUrl: 'docs.flutter.dev',
    category: 'Official & Docs',
    image: 'images/showcase/flutter_docs.png',
  ),
  ShowcaseItem(
    title: 'Flutter & Dart Blogs',
    url: 'https://flutter.dev/blog',
    displayUrl: 'flutter.dev/blog',
    category: 'Official & Docs',
    image: 'images/showcase/flutter_blog.png',
  ),
  ShowcaseItem(
    title: 'CIACH by LeanCode',
    url: 'https://ciach.leancode.co/',
    displayUrl: 'ciach.leancode.co',
    category: 'Developer Tools',
    image: 'images/showcase/ciach_leancode.png',
  ),
  ShowcaseItem(
    title: 'Advanced Forms by LeanCode',
    url: 'https://advanced-forms.leancode.co/',
    displayUrl: 'advanced-forms.leancode.co',
    category: 'Developer Tools',
    image: 'images/showcase/advanced_forms.png',
  ),
  ShowcaseItem(
    title: 'Flutter Friends',
    url: 'https://flutterfriends.dev/',
    displayUrl: 'flutterfriends.dev',
    category: 'Events',
    image: 'images/showcase/flutterfriends.png',
  ),
  ShowcaseItem(
    title: 'RACCT',
    url: 'https://racct.com/',
    displayUrl: 'racct.com',
    category: 'Enterprise',
    image: 'images/showcase/racct.png',
  ),
  ShowcaseItem(
    title: 'Maya Organic Beauty',
    url: 'https://mayaorganicbeauty.com/',
    displayUrl: 'mayaorganicbeauty.com',
    category: 'E-Commerce',
    image: 'images/showcase/mayaorganicbeauty.png',
  ),
  ShowcaseItem(
    title: 'Skystone Apps',
    url: 'https://skystoneapps.com/',
    displayUrl: 'skystoneapps.com',
    category: 'Agency',
    image: 'images/showcase/skystoneapps.png',
  ),
  ShowcaseItem(
    title: 'Crabble',
    url: 'https://crabble.app/',
    displayUrl: 'crabble.app',
    category: 'Web App',
    image: 'images/showcase/crabble.png',
  ),
  ShowcaseItem(
    title: 'Deepyr Doc',
    url: 'https://deepyr-doc.web.app/',
    displayUrl: 'deepyr-doc.web.app',
    category: 'Developer Tools',
    image: 'images/showcase/deepyr_doc.png',
  ),
  ShowcaseItem(
    title: 'BlocSignal',
    url: 'https://blocsignal.dev/',
    displayUrl: 'blocsignal.dev',
    category: 'Developer Tools',
    image: 'images/showcase/blocsignal.png',
  ),
];
