// [sample=5] Weather Api
import 'package:jaspr/dom.dart';
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
  Component build(BuildContext context) {
    return .fragment([
      SearchBar(
        placeholder: 'Enter Location',
        onSearch: (value) {
          setState(() => updateWeather(value));
        },
      ),
      FutureBuilder<CurrentWeather>(
        future: weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SimpleWeather(snapshot.data!);
          } else if (snapshot.hasError) {
            return .text('Error: ${snapshot.error}');
          } else {
            return .text('Loading');
          }
        },
      ),
    ]);
  }
}

class SimpleWeather extends StatelessComponent {
  const SimpleWeather(this.weather, {super.key});

  final CurrentWeather weather;

  @override
  Component build(BuildContext context) {
    return div(classes: 'weather', [
      img(src: weather.condition.icon),
      div(classes: 'info', [
        h1([.text('${weather.temp}°')]),
        span([.text('${weather.location.name}, ${weather.location.country}')]),
      ]),
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
  Component build(BuildContext context) {
    return div(classes: 'searchbar', [
      input(
        type: InputType.text,
        attributes: {if (component.placeholder != null) 'placeholder': component.placeholder!},
        onInput: (String value) {
          setState(() => search = value);
        },
      ),
      button(
        onClick: () {
          component.onSearch(search);
        },
        [.text('Search')],
      ),
    ]);
  }
}
