import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:world_time/controller/loader_controller.dart';

class WorldTime {
  String location; //location name for the UI
  String? time; // the time in that location
  String? flag; // URL to an asset flag icon
  String? url; //location url for API endpoint
  bool? isDaytime;

  static const _endPoint = "http://worldtimeapi.org/api/timezone";
  static const _weatherAPI = "https://api.openweathermap.org/data/2.5/weather";
  var weatherData;

  // Constructor
  WorldTime({required this.location, this.flag, this.url});

  Future<void> getTime() async {
    // Future is like promise in JS, void means that i will return void but only when the function is fully complete
    try {
      var url_path = Uri.parse('$_endPoint/$url');
      Response response = await get(url_path);
      Map data = jsonDecode(response.body);
      DateTime now = DateTime.parse(data["datetime"]);
      int offset = int.parse(data["utc_offset"].substring(1, 3));
      String operator = data["utc_offset"].substring(0, 1);
      if (operator == "+") {
        now = now.add(new Duration(hours: offset));
      } else if (operator == "-") {
        now = now.subtract(new Duration(hours: offset));
      }
      //Set time property
      time = DateFormat.jm().format(now);
      isDaytime = now.hour > 6 && now.hour < 20 ? true : false;
    } catch (e) {
      print(e);
      time = "could not get time data";
    }
  }

  static Future<List<WorldTime>> getCountriesList() async {
    var url_path = Uri.parse(_endPoint);
    Response response = await get(url_path);
    List data = jsonDecode(response.body);
    List<WorldTime> countryList = data.map((e) {
      String cityName = e.substring(e.lastIndexOf(' ') + 1);

      cityName = cityName.replaceAll('_', ' ');

      return WorldTime(url: e, location: cityName);
    }).toList();
    return countryList;
  }

  final controller = Get.put(LoaderController());

//  controller.getWeather(String location,var weatherData)

  Future<void> getWeather(String finalCityNme) async {
    try {
      final endIndex = location.contains("/")?location.split("/")[1]:location;

      final finalCityName = controller.textHide.value == false
          ? finalCityNme
          : endIndex;

           print("finalCityName ==============>>>>>>  $finalCityName");
      // print(location.substring(endIndex, location.length));
      var url_path = Uri.parse(
          '$_weatherAPI?q=${finalCityName}&appid=441da477a820a1292657bf1849af44eb&lang=de&units=metric');
      Response response = await get(url_path);
      print("response datat ==============>>>>>>  ${response.body}");
      Map data = jsonDecode(response.body);
      weatherData = data;
    } catch (e) {
      print(e);
    }
  }
}
