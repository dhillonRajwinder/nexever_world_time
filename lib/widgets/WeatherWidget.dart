import 'package:flutter/material.dart';

// ignore: must_be_immutable
class WeatherWidget extends StatelessWidget {
  var weatherData;
  //var list;
  WeatherWidget({required this.weatherData, });

  @override
  Widget build(BuildContext context) {
    final Locale appLocale = Localizations.localeOf(context);
    print(weatherData['main']['temp'].round());
    return Text(
        "${weatherData['main']['temp'].round()}° ${weatherData['weather'][0]['description']}",
        style: TextStyle(fontSize: 28, letterSpacing: 2, color: Colors.white));
  }
}
