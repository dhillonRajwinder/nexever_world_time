import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:world_time/pages/choose_location.dart';
import 'package:world_time/pages/home.dart';
import 'package:world_time/pages/loading.dart';

void main() {
  
  runApp(GetMaterialApp(

    
    initialRoute: '/',
    routes: {
      //map
      '/': (context) {
        return const Loading();
      },
      "/home": (context) {
        return Home();
      },
      "/location": (context) {
        return ChooseLocation();
      }
    },
  ));
}
