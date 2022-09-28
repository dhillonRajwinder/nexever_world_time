import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get.dart';

class LoaderController extends GetxController {
  RxBool textHide = false.obs;
  var AddressCityName = ''.obs;
  var location = 'Null, Press Button'.obs;
  var Address = 'search'.obs;

  @override
  void onInit() {
    super.onInit();
    print(("=====>onInit<======"));
    firstFun();
  }

  firstFun() async {
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
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    // print(tdata);
    Placemark place = placemarks[0];
    AddressCityName.value = '${place.locality}';
    Address.value =
        //'${place.street}, ${place.subLocality},${place.postalCode},
        ' ${place.locality}/${place.country}';
  }
}
