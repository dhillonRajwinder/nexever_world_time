import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

class LoaderController extends GetxController {
  RxBool textHide = false.obs;
  final AddressCityName = ''.obs;
  final location = 'Null, Press Button'.obs;
  final Address = 'search'.obs;
  final cityname = ''.obs;
  var weatherData;
  static const _weatherAPI = "https://api.openweathermap.org/data/2.5/weather";
  @override
  void onInit() {
    super.onInit();
    print(("=====>onInit<======"));
    // firstFun();
    print("===>===>${AddressCityName.value}===>===>");

    print("===>===>${Address.value}===>===>");
  }

  Future firstFun() async {
    Position position = await _getGeoLocationPosition();
    location.value = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    GetAddressFromLatLong(position);
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      //print(placemarks);
      // print(tdata);
      Placemark place = placemarks[0];
      AddressCityName.value = '${place.locality}';
      //updatev(AddressCityName.value);
      Address.value =
          //'${place.street}, ${place.subLocality},${place.postalCode},
          ' ${place.locality}/${place.country}';
      update();
    } catch (e) {
      rethrow;
    }
  }

  // updatev(value) async{
  //    final endIndex = location.split("/")[1];

  //     final finalCityName = textHide.value == false
  //         ? value
  //         : endIndex;
  //     // print(location.substring(endIndex, location.length));
  //     var url_path = Uri.parse(
  //         '$_weatherAPI?q=${finalCityName}&appid=441da477a820a1292657bf1849af44eb&lang=de&units=metric');
  //          var response = await get(url_path);
  //     Map data = jsonDecode(response.body);
  //     weatherData = data;
  // }
}
