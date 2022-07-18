// [sample=5] Weather Api
import 'package:jaspr/jaspr.dart';

import 'api.dart';

void main() {
  runApp(App());
}

class App extends StatefulComponent {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final WeatherApi api = WeatherApi();
  late Future<CurrentWeather> weatherFuture;

  @override
  void initState() {
    super.initState();
    updateWeather('Munich');
  }

  void updateWeather(String location) {
    weatherFuture = api.getWeather(location);
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield SearchBar(
      placeholder: 'Enter Location',
      onSearch: (value) {
        setState(() => updateWeather(value));
      },
    );

    yield FutureBuilder<CurrentWeather>(
      future: weatherFuture,
      builder: (context, snapshot) sync* {
        if (snapshot.hasData) {
          yield SimpleWeather(snapshot.data!);
        } else if (snapshot.hasError) {
          yield Text('Error: ${snapshot.error}');
        } else {
          yield Text('Loading');
        }
      },
    );
  }
}

class SimpleWeather extends StatelessComponent {
  const SimpleWeather(this.weather, {Key? key}) : super(key: key);

  final CurrentWeather weather;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['weather'],
      children: [
        DomComponent(
          tag: 'img',
          attributes: {'src': weather.condition.icon},
        ),
        DomComponent(
          tag: 'div',
          classes: ['info'],
          children: [
            DomComponent(tag: 'h1', child: Text('${weather.temp}°')),
            DomComponent(
              tag: 'span',
              child: Text('${weather.location.name}, ${weather.location.country}'),
            )
          ],
        )
      ],
    );
  }
}

class SearchBar extends StatefulComponent {
  const SearchBar({required this.onSearch, this.placeholder, Key? key}) : super(key: key);

  final ValueChanged<String> onSearch;
  final String? placeholder;

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  String search = '';

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['searchbar'],
      children: [
        DomComponent(
          tag: 'input',
          attributes: {'type': 'text', if (component.placeholder != null) 'placeholder': component.placeholder!},
          events: {
            'input': (e) {
              setState(() => search = e.target.value);
            }
          },
        ),
        DomComponent(
          tag: 'button',
          events: {
            'click': (e) {
              component.onSearch(search);
            }
          },
          child: Text('Search'),
        ),
      ],
    );
  }
}
