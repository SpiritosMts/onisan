import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:onisan/components/dialog/bottomSheet.dart';
import 'package:onisan/components/json/jsonFormat.dart';
import 'package:onisan/components/myTheme/themeManager.dart';
import 'package:onisan/components/snackbar/topAnimated.dart';
import 'package:sizer/sizer.dart';

import '../cscpicker/csc_picker.dart';

int calculateDistance(double lat1, double lon1, double lat2, double lon2, {bool inMiles = false}) {
  const int radiusOfEarthKm = 6371; // Radius of the Earth in kilometers
  const double radiusOfEarthMiles = 3958.8; // Radius of the Earth in miles

  // Convert latitude and longitude from degrees to radians
  double lat1Rad = lat1 * pi / 180;
  double lon1Rad = lon1 * pi / 180;
  double lat2Rad = lat2 * pi / 180;
  double lon2Rad = lon2 * pi / 180;

  // Haversine formula
  double dLat = lat2Rad - lat1Rad;
  double dLon = lon2Rad - lon1Rad;

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1Rad) * cos(lat2Rad) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = inMiles ? radiusOfEarthMiles * c : radiusOfEarthKm * c;

  // Return distance as an integer
  return distance.round();
}

Future<Placemark?> getNonArabicStreetAndLocalityPlacemark(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

    final arabicRegex = RegExp(r'[\u0600-\u06FF]');

    for (int i = 0; i < placemarks.length; i++) {
      Placemark placemark = placemarks[i];
      bool isStreetNonArabic = placemark.street != null && !arabicRegex.hasMatch(placemark.street!);
      bool isLocalityNonArabic = placemark.locality != null && !arabicRegex.hasMatch(placemark.locality!);

      if (isStreetNonArabic && isLocalityNonArabic) {

        return placemark; // Return the first valid placemark
      }
    }
  } catch (e) {
    print('Failed to get placemarks: $e');
  }

  return null; // Return null if no valid placemark is found
}


Future<Map<String,dynamic>> getCurrentLocationInfo() async {

  Map<String,dynamic>? locationInfo;
  try {

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //animatedSnack(message: "Location services are disabled");

      return Future.error('## Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        animatedSnack(message: "Location permission denied");

        return Future.error('## Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      //animatedSnack(message: "Location permission denied");
      showBottomSheetDialog(
          title: "Location Permission Required",
          description: "Location permission has been denied. Please enable it in the app settings to use this feature.",
          positiveButtonText: "open settings",
          onPositivePressed: () {
            Geolocator.openAppSettings();
          }
      );
      return Future.error('## Location permissions are permanently denied, we cannot request permissions.');
    }

    print('## Location permissions Granted');


    Position position =await Geolocator.getCurrentPosition();



    Placemark? place = await getNonArabicStreetAndLocalityPlacemark(
      position.latitude,
      position.longitude,
    );



    locationInfo={
      'lat': position.latitude??0.0,
      'lng': position.longitude??0.0,
      'country': place!.country ?? '',
      'city': place!.locality ?? '',
      'street': place!.street ?? '',
    };

    printJson(locationInfo);






  } catch (e) {

    print("## error cant found current location: $e");
  }finally{
    return locationInfo!;
  }
}

void showPickLocationManually({
  required Map<String, dynamic> currentValues,
  required Function(Map<String, dynamic>) onSave,
  String iconPath = 'assets/images/icons/flag.png'
}) {
  bool isChanged = false;
  String selectedCountry = '';
  String selectedState = ''; // Add a variable for State
  String selectedCity = '';

  bool allFieldsSelected() {
    return selectedCountry.isNotEmpty && selectedState.isNotEmpty && selectedCity.isNotEmpty;
  }

  void checkIfChanged() {
    isChanged = allFieldsSelected() &&
        (currentValues['country'] == null || selectedCountry != currentValues['country']) ||
        (currentValues['state'] == null || selectedState != currentValues['state']) ||
        (currentValues['city'] == null || selectedCity != currentValues['city']);

    print("## changed country=$selectedCountry, state=$selectedState, city=$selectedCity ");
  }


  String desc = 'Select your location';
  double titleIconSpace = 2.h;
  double iconSize = 23;
  EdgeInsets titlePadding = EdgeInsets.fromLTRB(10, 5, 5, 0);

  showModalBottomSheet(
    context: Get.context!,
    backgroundColor: Cm.bgCol2,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (BuildContext context, ScrollController scrollController) {
          return Stack(
            children: [
              // Scrollable content
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                  decoration: BoxDecoration(
                    color: Cm.bgCol2,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.close, color: Cm.textHintCol2),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                            IconButton(
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.check,
                                  color: isChanged ? Cm.primaryColor : Cm.textHintCol2),
                              onPressed: () {
                                if (isChanged) {
                                  Map<String, dynamic> selectedValues = {
                                    'country': selectedCountry,
                                    'state': selectedState,
                                    'city': selectedCity,
                                  };
                                  onSave(selectedValues); // Call the onSave function
                                  Get.back();
                                  print("## saved $selectedValues");
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Padding(
                          padding: titlePadding,
                          child: Row(
                            children: [
                              Image.asset(
                                iconPath,
                                height: iconSize,
                                width: iconSize,
                              ),
                              SizedBox(width: titleIconSpace),
                              Flexible(
                                child: Text(
                                  desc,
                                  style: TextStyle(
                                    color: Cm.textCol2,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
                          child: Divider(
                            color: Cm.textHintCol2.withOpacity(0.5),
                            thickness: 1,
                            endIndent: 10,
                            indent: 10,
                          ),
                        ),
                        // pick location
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: Column(
                            children: [
                              /// Adding CSC Picker Widget in app
                              CSCPicker(
                                showStates: true,
                                showCities: true,
                                flagState: CountryFlag.DISABLE,
                                dropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                ),
                                disabledDropdownDecoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  color: Colors.grey.shade300,
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                ),
                                countrySearchPlaceholder: "Pick your country",
                                stateSearchPlaceholder: "Pick your state",
                                citySearchPlaceholder: "Pick your city",
                                countryDropdownLabel: "Country",
                                stateDropdownLabel: "State",
                                cityDropdownLabel: "City",
                                defaultCountry: CscCountry.Canada,
                                selectedItemStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                dropdownHeadingStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                dropdownItemStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                dropdownDialogRadius: 10.0,
                                searchBarRadius: 10.0,
                                onCountryChanged: (value) {
                                  selectedCountry = value ?? selectedCountry;
                                },
                                onStateChanged: (value) {
                                  selectedState = value ?? selectedState;
                                },
                                onCityChanged: (value) {
                                  selectedCity = value ?? selectedCity;
                                  checkIfChanged();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Dragger icon
              Positioned(
                top: 8,
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Cm.textHintCol2,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
