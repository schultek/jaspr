import 'dart:convert';

import 'package:http/http.dart';

const apiKey = '7e583d1853f749da83d120354222604';

class WeatherApi {
  Future<CurrentWeather> getWeather(String location) async {
    var response = await get(Uri.parse('https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$location&aqi=no'));
    if (response.statusCode == 200) {
      return CurrentWeather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      var error = jsonDecode(response.body);
      throw error['error']['message'];
    } else {
      throw 'Unknown (${response.statusCode})';
    }
  }
}

class CurrentWeather {
  final double temp;
  final WeatherCondition condition;
  final WeatherLocation location;

  CurrentWeather.fromJson(Map<String, dynamic> json)
      : temp = json['current']['temp_c'],
        location = WeatherLocation.fromJson(json['location']),
        condition = WeatherCondition.fromJson(json['current']['condition']);
}

class WeatherLocation {
  final String name;
  final String country;

  WeatherLocation.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        country = json['country'];
}

class WeatherCondition {
  final String text;
  final String icon;

  WeatherCondition.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        icon = json['icon'];
}
