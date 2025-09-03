import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaspr/jaspr.dart';

@client
class SponsorsList extends StatefulComponent {
  const SponsorsList({super.key});

  @override
  State createState() => SponsorsListState();
}

class SponsorsListState extends State<SponsorsList> {
  bool loaded = false;
  List sponsors = [];

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      loadSponsorsData();
    }
  }

  Future<void> loadSponsorsData() async {
    final response = await http.get(Uri.parse('https://ghs.vercel.app/v3/sponsors/schultek'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final {"sponsors": {"current": List sponsors}} = data;

    setState(() {
      this.sponsors = sponsors;
      loaded = true;
    });
  }

  @override
  Component build(BuildContext context) {
    return div(classes: 'sponsors-list', [
      if (!loaded)
        for (var i = 0; i < 6; i++) div(classes: 'sponsor-avatar', [])
      else
        for (final sponsor in sponsors)
          a(href: "https://github.com/${sponsor['username']}", classes: 'sponsor-avatar', [
            img(src: sponsor['avatar'], alt: sponsor['username']),
          ]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
        css('.sponsors-list', [
          css('&').styles(
            display: Display.flex,
            flexDirection: FlexDirection.row,
            flexWrap: FlexWrap.wrap,
            gap: Gap.all(0.4.rem),
          ),
          css('& > *', [
            css('&').styles(
              width: 2.rem,
              height: 2.rem,
              radius: BorderRadius.circular(1.rem),
              overflow: Overflow.hidden,
              backgroundColor: Colors.gray,
            ),
            css('img').styles(width: 100.percent),
          ]),
        ]),
      ];
}
