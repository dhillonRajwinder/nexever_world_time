import 'dart:io';

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
  Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final LoaderController controller = Get.find();
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
  //   setCurrentValues();
  //   print(("=====>initState<======"));
  // }

  // String? currentDefaultSystemLocale;
  // List<Locale>? currentSystemLocales;

  // // Here we read the current locale values
  // void setCurrentValues() {
  //   currentSystemLocales = WidgetsBinding.instance.window.locales;
  //   currentDefaultSystemLocale = Platform.localeName;
  // }

  @override
  Widget build(BuildContext context) {
    data =
        data.isEmpty ? ModalRoute.of(context)!.settings.arguments as Map : data;


    print("Dataaaa--->"+data.toString());
    String bgImage = "";
    // set background
    setState(() {

      bgImage = 'day.jpg';
      if (data['isDaytime']!=null) {
        bgImage = data['isDaytime'] ? 'day.jpg' : 'night.jpg';

      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          WorldTime instance = WorldTime(
            location: data["location"],
            url: data["url"],
          );
          if (await HelperFunctions.checkIntenetConnection()) {
            await instance.getTime();
            await instance.getWeather(controller.AddressCityName.value);
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
                  Obx(() => Text('${controller.AddressCityName}',
                      style: TextStyle(
                        color: Colors.white,
                      ))),
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
                    //code : widget.systemLocales,
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
