import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:world_time/controller/loader_controller.dart';

//import 'package:location/location.dart' as ;
import 'package:world_time/services/helperFunctions.dart';
import 'package:world_time/services/world_time.dart';
import 'package:localstore/localstore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_time/widgets/WeatherWidget.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = Get.put(LoaderController());
  Map data = {};
  final db = Localstore.instance;
  var currentLocation = '';
  // String location = 'Null, Press Button';
  // String Address = 'search';
  // String AddressCityName = 'search';
  String tdata = DateFormat("h:mm a").format(DateTime.now());

  // @override
  // initState() {
  //   super.initState();
  //   firstFun();
  //   print(("=====>initState<======"));
  // }

  // firstFun() async {
  //   Position position = await _getGeoLocationPosition();
  //   location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
  //   GetAddressFromLatLong(position);
  // }

  // Future<Position> _getGeoLocationPosition() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     await Geolocator.openLocationSettings();
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   return await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);
  // }

  // Future<void> GetAddressFromLatLong(Position position) async {
  //   List<Placemark> placemarks =
  //       await placemarkFromCoordinates(position.latitude, position.longitude);
  //   print(placemarks);
  //   print(tdata);
  //   Placemark place = placemarks[0];
  //   AddressCityName = '${place.locality}';
  //   Address =
  //       //'${place.street}, ${place.subLocality},${place.postalCode},
  //       ' ${place.locality}/${place.country}';
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    data =
        data.isEmpty ? ModalRoute.of(context)!.settings.arguments as Map : data;
    String bgImage = "";
    // set background
    setState(() {
      bgImage = data['isDaytime'] ? 'day.jpg' : 'night.jpg';
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          WorldTime instance =
              WorldTime(location: data["location"], url: data["url"]);
          if (await HelperFunctions.checkIntenetConnection()) {
            await instance.getTime();
            await instance.getWeather();
            setState(() {
              data["location"] = instance.location;
              data["time"] = instance.time;
              data["isDaytime"] = instance.isDaytime;
              data["weatherData"] = instance.weatherData;
            });
          } else {
            HelperFunctions.showNoConnectionDialog(context);
          }
        },
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/$bgImage'), fit: BoxFit.cover)),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 120, 0, 0),
                child: Column(children: <Widget>[
                  // Text('${Address}',
                  //     style: TextStyle(color: Colors.white, letterSpacing: 2)),
                  TextButton.icon(
                      onPressed: () async {
                        dynamic result =
                            await Navigator.pushNamed(context, "/location");
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString("location", result["location"]);
                        prefs.setString("url", result["url"]);
                        if (result != null) {
                          setState(() {
                            data = result;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.edit_location,
                        color: Colors.grey[300],
                      ),
                      label: Text(
                        'Edit Location',
                        style: TextStyle(color: Colors.white, letterSpacing: 2),
                      )),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() => Expanded(
                            child: Text(
                              controller.textHide.value == false
                                  ? '${controller.Address}'
                                  : data["location"],
                              style: TextStyle(
                                  fontSize: 28,
                                  letterSpacing: 2,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )),
                    ],
                  ),
                  SizedBox(height: 20),
                  Obx(() => Text(
                        controller.textHide.value == false
                            ? tdata
                            : data['time'],
                        style: TextStyle(fontSize: 66, color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                  SizedBox(height: 20),
                  WeatherWidget(
                    weatherData: data["weatherData"],
                  ),
                ]),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
