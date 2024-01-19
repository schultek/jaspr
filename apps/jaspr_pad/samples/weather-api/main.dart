// [sample=5] Weather Api
import 'package:jaspr/jaspr.dart';

import 'api.dart';

void main() {
  runApp(App());
}

class App extends StatefulComponent {
  const App({super.key});

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
  const SimpleWeather(this.weather, {super.key});

  final CurrentWeather weather;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'weather', [
      img(src: weather.condition.icon),
      div(classes: 'info', [
        h1([text('${weather.temp}°')]),
        span([text('${weather.location.name}, ${weather.location.country}')])
      ])
    ]);
  }
}

class SearchBar extends StatefulComponent {
  const SearchBar({required this.onSearch, this.placeholder, super.key});

  final ValueChanged<String> onSearch;
  final String? placeholder;

  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBar> {
  String search = '';

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'searchbar', [
      input(
        type: InputType.text,
        attributes: {if (component.placeholder != null) 'placeholder': component.placeholder!},
        onInput: (value) {
          setState(() => search = value);
        },
        [],
      ),
      button(
        onClick: () {
          component.onSearch(search);
        },
        [text('Search')],
      ),
    ]);
  }
}
